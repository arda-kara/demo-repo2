
---

# VSLAM System Hardware Accelerator

## Description

This project is a hardware accelerator designed to enhance VSLAM (Visual Simultaneous Localization and Mapping) systems. It specifically aims to filter images for use in VSLAM algorithms, with a focus on parallel usage with the VINS-Mono algorithm. Currently a work in progress, this hardware accelerator filters images into grayscale, optimizing the performance of VINS-Mono.

## Getting Started

### Dependencies

- All dependencies required for the VINS-Mono algorithm.
- VHDL environment for code development and simulation.
  - This project is written in VHDL; ensure that your development environment supports VHDL projects.

### Installing

To install this project, follow these steps:

```
git clone https://github.com/arda-kara/vslam-hardware-accelerator.git
cd vslam-hardware-accelerator
```
Then, open the project in a VHDL-compatible IDE, such as Vivado.

### Executing program

Currently, this section is under development. Instructions on how to execute the program will be updated in future versions.

## Usage

This hardware accelerator is designed as a grayscale filter for the VINS-Mono algorithm. It operates as follows:

- Receives pixel data via SPI (Serial Peripheral Interface).
- Processes the data to convert images into grayscale.
- Transmits the processed data back to the master device (intended to be a Raspberry Pi 4) via SPI.

This setup aims to enhance the efficiency of the VINS-Mono algorithm in real-time VSLAM applications.

## Contributing

Contributions to this project are welcome. Please follow these steps to contribute:

1. Fork the project.
2. Create your feature branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -m 'Add some YourFeature'`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a Pull Request.

## Contact

Arda Kara - ardakara1881@hotmail.com

Project Link: [https://github.com/arda-kara/vslam-hardware-accelerator](https://github.com/yourusername/vslam-hardware-accelerator)

---
