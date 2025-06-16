# Authors: (2025.04) Jair Pereira and Toshio Moriya

import argparse
import numpy as np
from functools import partial

import logging
logger = logging.getLogger(__name__)

def relativistic_electron_wavelength(voltage_kV):
    """
    Calculate the relativistically corrected deBroglie wavelength of an electron
        this function uses precomputed values from the full equation.

    Parameters:
        voltage_kV (float): accelerating voltage in kV
        
    Returns:
        lambda_ (float): the relativistically corrected electron wavelength in Ångströms [Å]

    Constants:
        1022   = 2*rest_energy (electron rest energy = 511 [keV])
        12.398 = h*c [eV Å] from Planck's constant [Js] and speed of light [m/s]
    """
    return 12.398 / np.sqrt(voltage_kV * (1022.0 + voltage_kV)) # [Å]

def ctf_period(defocus_A, cs_A, lambda_, frequency):
    """
    Calculate the local oscillation period of the Contrast Transfer Function (CTF) at a given spatial frequency.
    
    This function solves for the CTF oscillation period using a fourth-order polynomial derived from the 
        phase condition: $\gamma(f + T) - \gamma(f) = 1 $ where 
        $\gamma(f) = 2\pi \left( defocus \lambda frequency^2 - \frac{cs \lambda^3 frequency^4}{2} \right)$.
    
    The result represents the distance between two consecutive zero-crossings of the CTF at
        the specified spatial frequency, which can be used to assess aliasing risk in Fourier space.
    
    Parameters:
        defocus_A (float) : defocus value in [Å].
        cs_A      (float) : spherical aberration constant in [Å].
        lambda_   (float) : relativistic electron wavelength in [Å].
        frequency (float) : spatial frequency in [Å⁻¹] at which to compute the CTF oscillation period.

    Returns:
        float : The smallest CTF oscillation period [Å⁻¹].

	Notes:
		if there is need to optimize this function  try
			1) precompute A and B, or
			2) solve for T: 2*z*lambda*f^2 - c*lambda^3*f^4 = 2*z*lambda*(f+T)^2 - c*(lambda^3)*(f+T)^4 +1
    """
    # pre-computing (if this function is a bottle-neck, we could cache A and B)
    A  = 0.5 * defocus_A * lambda_
    B  = 0.25 * cs_A * lambda_**3
    f2 = frequency**2

    # solve a 4th order polynomial to compute the local CTF period
    rot = np.roots([B, 4*B*frequency, 6*B*f2 - A, 4*B*f2*frequency - 2*A*frequency, -1.0])

    return min(abs(rot))

def ctf_limit(boxsize, pixel_size, voltage, defocus, cs, limit_resolution=15):
    """
    Calculate the Fourier pixel index and spatial frequency at which 
        aliasing will occur for a given microscope setup.

    Parameters:
      boxsize    (int)  : image length in [pixel].
      pixel_size (float): real space length [Å].
      defocus    (float): defocus value in [µm].
      cs         (float): spherical aberration constant in [mm].
      voltage    (float): microscope accelerating voltage in [kV].
    
    Returns:
      tuple: (Fourier pixel index, spatial frequency in [Å⁻¹])
                 where aliasing will occur.
    
    Notes: 
        1. frequency_bin_width uses n_bins, not (n_bins-1), to exactly match the original script.
    """
    logger.info("")
    logger.info(f"CTF Limit calculation using boxsize={boxsize}, pixel_size={pixel_size}, defocus={defocus}, cs={cs}, voltage={voltage}")

    # 1. Number of unique frequency bins (from 0 to Nyquist)
    n_frequency_bins = boxsize // 2 + 1  # half of the image +1 in fourier space (removing negatives and zero)
    logger.info(f"Number of unique frequency bins: {n_frequency_bins} (from 0 to Nyquist)")
  
    # 2. Width of frequency bins in fourier space [Å⁻¹]
    nyquist_frequency   = 1.0/(2*pixel_size) # [Å⁻¹] maximum representable frequency for this pixel size
    frequency_bin_width = nyquist_frequency / n_frequency_bins # [Å⁻¹]
    logger.info(f"Nyquist Frequency: {nyquist_frequency} [Å⁻¹]")
    logger.info(f"Width of frequency bins in fourier space: {frequency_bin_width} [Å⁻¹]")
 
    # 3. Frequency of the largest resolvable wavelength for this bin width (aliasing threshold)
    threshold_frequency = 2*frequency_bin_width # [Å⁻¹]
    logger.info(f"Aliasing Threshold: {threshold_frequency} [Å⁻¹]")
    threshold_user = 1/limit_resolution
    logger.info(f"User defined threshold: {threshold_user} [Å⁻¹]")

    # 4. Wrapper for ctfperiod, binding fixed parameters that needed conversion
    partial_ctf_period = partial(ctf_period,
                                defocus_A = defocus*1e4,  # Convert µm to Å
                                cs_A      = cs*1e7,       # Convert mm to Å
                                lambda_   = relativistic_electron_wavelength(voltage_kV=voltage) # [Å]
    )

    # 5. If no aliasing detected, default to Nyquist
    bin_result       = n_frequency_bins-1 # index of last bin
    frequency_result = nyquist_frequency  # maximum frequency
    found = False

    # 6. Find the first frequency where the CTF oscillation period exceeds the threshold frequency
    logger.info("Finding CTF oscillation period that exceed the threshold frequency...")
    for bin_i in range(n_frequency_bins-1, 1, -1): # from nyquist bin to lower frequencies        
        # 6a. Map Fourier‐bin index to spatial frequency (bin_i frequency)
        spatial_frequency = (bin_i /(n_frequency_bins-1)) * nyquist_frequency # [Å⁻¹]

        # 6b. Compute CTF period in fourier space  
        ctf_spacing = partial_ctf_period(frequency=spatial_frequency) # [Å⁻¹]
        logger.info(f"\tCTF spacing: {ctf_spacing}[Å⁻¹] > {threshold_frequency}[Å⁻¹]? {ctf_spacing > threshold_frequency}")

        # 6c. If the CTF period (in fourier-space) exceeds the allowed sampling window
        if ctf_spacing > threshold_frequency or ctf_spacing > threshold_user:
            bin_result       = int((spatial_frequency / frequency_bin_width) + 0.5)
            frequency_result = spatial_frequency
            found = True
            break # return (bin index, spatial frequency) at aliasing limit

    if not found:
        logger.info(f"No aliasing detected, defaulting to Nyquist frequency.")
    logger.info(f"Frequency where aliasing will occur: {frequency_result} [Å⁻¹] at bin #{bin_result} with resolution {1/frequency_result} [Å]")
    logger.info("")

    return bin_result, frequency_result

def phaseshift_ctf(lambda_, pixel_size, defocus, cs, boxsize): #_heel
    '''
    from: Principles of Phase Contrast (Electron) Microscopy - Marin van Heel
        - positive values for underfocus
        - PhCTF(f) = sin(\frac{2\pi}{\lambda}[\frac{-C_s \lambda ^4 f^4}{4} + \frac{\Delta F \lambda ^2 f^2}{2}])

    arguments:
        - lambda_: relativistic electron wavelength in Å
        - pixel_size
        - defocus in Å
        - cs in Å (it actually asks in mm, but the units wont cancel out)
        - boxsize
        
    '''
    nyquist = 1/(2*pixel_size)
    f  = nyquist/(boxsize//2) * np.arange(1+boxsize//2, dtype=np.float64) # spatial frequencies
    # f = np.fft.fftfreq(boxsize, d=pixel_size)

    # complete
    # a = 2*np.pi/lambda_
    # b = -(cs* lambda_**4 * f**4)/4
    # c = (defocus * lambda_**2 * f**2)/2
    # gamma = a*(b+c) # = phase_shift
    # phaseshift_ctf = np.sin(gamma)

    # simplified
    f2 = f**2
    a = (-cs * (lambda_**3) * f2)/2
    b = defocus * lambda_
    gamma = np.pi*f2*(a+b)
    phaseshift_ctf = np.sin(gamma)    

    return f, phaseshift_ctf

def phaseshift_ctf2d(lambda_, pixel_size, defocus, cs, boxsize):
    nyquist = 1/(2*pixel_size)
    # f  = nyquist/(boxsize//2) * np.arange(1+boxsize//2, dtype=np.float64)
    f = np.fft.fftshift(np.fft.fftfreq(boxsize, d=pixel_size))
    
    fx, fy = np.meshgrid(f, f)
    s = np.sqrt(fx**2 + fy**2)
    
    s2 = s**2
    a = (-cs * lambda_**3 * s2)/2
    b = defocus * lambda_
    gamma = np.pi*s2*(a+b)
    phaseshift_ctf = np.sin(gamma)    

    return s, phaseshift_ctf

if __name__ == "__main__":
	# python ctf.py -b 400 -p 1.2 -v 300 -d -0.8 -c 2.7 -q
    parser = argparse.ArgumentParser(description="Estimate the CTF aliasing limit based on microscope parameters.")	
    parser.add_argument("-b", "--boxsize",    type=int,   required=True, help="Boxsize in pixels (size of the extracted image square).")
    parser.add_argument("-p", "--pixel_size", type=float, required=True, help="Pixel size in [Å].")
    parser.add_argument("-v", "--voltage",    type=float, required=True, help="Microscope accelerating voltage in [kV].")
    parser.add_argument("-d", "--defocus",    type=float, required=True, help="Defocus value in micrometers [µm].")
    parser.add_argument("-c", "--cs",         type=float, required=True, help="Spherical aberration constant (Cs) in millimeters [mm].")
    parser.add_argument("-limres", "--limit_resolution",  default=15, type=float, help="(Optional) Estimate CTF only up to this limiting resolution")
    parser.add_argument("-q", "--quiet",      action='store_true', help='Disable verbose output')
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO if not args.quiet else logging.WARNING, 
                        format="CTF LIMIT | %(levelname)s: %(message)s"
    )

    result = ctf_limit(args.boxsize, args.pixel_size, args.voltage, args.defocus, args.cs, args.limit_resolution)
    
    print(result)
