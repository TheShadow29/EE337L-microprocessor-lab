# EE337L-microprocessor-lab
To run dfu programmer on ubuntu 
https://sourceforge.net/projects/dfu-programmer/files/

Installation:

    * Extract the folder

    * Run './configure'

    * Run 'make'

    * Run 'sudo make install'

Burning hex file:

    * Make sure the pt51 is connected to your laptop. You should see it when you run 'lsusb'

    * Run 'sudo dfu-programmer at89c5131 erase'

    * Run 'sudo dfu-programmer at89c5131 flash hex_file.hex'. (Make sure you are in the directory of the hex file)