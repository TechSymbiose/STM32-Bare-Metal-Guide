# STM32 Bare Metal Tutorial

Welcome to a simple and complete generic STM32 Bare Metal Programming Tutorial !

# Contents

<!-- MarkdownTOC levels="1,2,3" autolink="true" style="ordered" -->

1. [Descritpion](#descritpion)
1. [Why Programming In Bare Metal ?](#why-programming-in-bare-metal-)
1. [Requirements](#requirements)
	1. [Hardware requirements](#hardware-requirements)
	1. [Software requirements](#software-requirements)
	1. [Files](#files)
		1. [Documentation](#documentation)
		1. [Source code](#source-code)
		1. [Makefile](#makefile)
1. [Organize our work](#organize-our-work)
	1. [My rules](#my-rules)
	1. [Create the project](#create-the-project)
1. [Configuration and programming](#configuration-and-programming)
	1. [Configure your linke script](#configure-your-linke-script)
1. [Bonus - Understand the makefile](#bonus---understand-the-makefile)

<!-- /MarkdownTOC -->

# Descritpion

STM32 are great electronics devices. Compared to Arduino cards, they are cheapper and way more powerful ! However, a STM32 can be harder to program and use the STM32CubeIDE can be really annoying, especially if we like free software and don't like IDe (like me).

Unfortunetaly, programming in Bare Metal (i.e. without IDE) is not very easy, that's why I decided to create a little tutorial to make it easier for beginner.

# Why Programming In Bare Metal ?

What a great question ! First, by programming in Bare Metal you're not stuck with an awful IDE. STM32CubeIDE does the job, but for me it's not very pleasant with the GUI to configure the STM32 in addition to unreadable and heavy code tags. Last, but not least, programming in bare metal is an awesome journey where you can do whatever you want, however you want. Futhermore, it is a great opportunity to better understand how STM32 cards work. So let's get started !

# Requirements

## Hardware requirements 

To follow this tutorial, all you need is you're computer with a Linux distribution and your favorite programming tool and a (Nucleo) STM32.

For this tutorial, I will use a Nucleo STM32G474RE, an amazing SMT32, but feel free to use what you have/like as it is a generic tutorial which will explain the process step by step for every STM32.

## Software requirements

To begin your STM32 bare metal journey, you will need some software tools :

- [STM32CubeIDE](https://www.st.com/en/development-tools/stm32cubeide.html) (don't worry, it's just for the beginning)
- arm-none-eabi : open your terminal and run the following commands :

```
sudo apt-get remove binutils-arm-none-eabi gcc-arm-none-eabi
sudo add-apt-repository ppa:team-gcc-arm-embedded/ppa
sudo apt-get update
sudo apt-get install gcc-arm-none-eabi
sudo apt-get install gdb-arm-none-eabi
```


## Files

To make it generic and suitable with every STM32, we need to download a few files ([documentation](#documentation), [source code](source-code) and the [makefile](#makefile)).

### Documentation

We can thank ST Microelectronics for making such amazing documentations about their products as we will need it throughout our journey. For each documentation, I will give a link to the one corresponding to the STM32G474RE I will use. All you need to do is clicking the *Download datasheet* button.

- The official datasheet of your STM32 ([STM32G4RE](https://www.st.com/en/microcontrollers-microprocessors/stm32g474re.html))
- The official manual reference of your STM32 serie ([STM32G4 series](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwjW0Yz-3Jf_AhWWUaQEHSG5DWQQFnoECBEQAQ&url=https%3A%2F%2Fwww.st.com%2Fresource%2Fen%2Freference_manual%2Frm0440-stm32g4-series-advanced-armbased-32bit-mcus-stmicroelectronics.pdf&usg=AOvVaw3ftHeU2N_xdW0o3rFDXRUg))
- The official Nucleo user manual for your STM32 ([STM32G4 Nucleo-64 boards](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwjLwpjL65f_AhVKU6QEHVLyCrYQFnoECBAQAQ&url=https%3A%2F%2Fwww.st.com%2Fresource%2Fen%2Fuser_manual%2Fdm00556337-stm32g4-nucleo-64-boards-mb1367-stmicroelectronics.pdf&usg=AOvVaw0BqEGEUKpUagL8S3uQSh38))

The STM32 datasheet will give you all the information of the chip (memory addresses and size, interfaces, features...). The official manual reference gives you general information about the series for your STM32 such as the memory mapping (great to write GPIO drivers for instance). Finally, the official Nucleo user manual will help you with your Nucleo board and the pin mapping.

Each time I will refer to a documentation, I will use as example the documentation from the board I use (STM32G474RE). Of course, apply the examples according to the documentation you use.

### Source code

To begin with bare metal programming you need to recover some files. The best and easiest way is to recover it from STM32CubeIDE. That will be the only time we use STM32CubeIDE. Simply open the IDE, create a new empty project :

File->New->STM32 Project->MCU/MPU Selector, search for the Commercial Part Number (STM32G474RET6 for example), select your nucleo board, type next, choose a name, type finish. Go through the folders to find the following files :

- From Drivers/CMSIS/Include/, recover :
	- cmsis\_armcc.h
	- cmsis\_armclang.h
	- cmsis\_compiler.h
	- cmsis\_gcc.h
	- cmsis\_iccarm.h
	- cmsis\_version.h
	- core\_mX.h (with X the serie of your STM32. As I use one from the STM32G4 serie, in my case it is core_m4.h)
	- mpu\_armv7.h
- From Drivers/CMSIS/Device/ST/STM32XXxx/Include (replace XX by your serie, still G4 in my case) :
	- stm32XXXXxx.h (replace XXX by your STM32, for me it's stm32g474xx.h)
	- stm32XXxx.h (same, replaceX X by the serie, stm32g4xx.h for me)
	- system\_stm32XXxx.h (system\_stm32g474xx.h)

In addition with these header files, you need 2 more files. First, the startup file with the '.s' extension :

- Core/Startup/startup\_stm32XXXXXXXX.s (startup_stm32g474retx.s)

Then, the linker script (with .ld extension). You can find these 2 linker script files for both the RAM and the FLASH from STM32CubeIDE (Drivers/STM32XXXXXXXX_FLASH.ld and Drivers/STM32XXXXXXXX_FLASH.ld). However, I advise you to use a unique file you can find [here](./core/startup/stm32g474re.ld). Simply rename this file to match your STM32. It is equivalent to both previous file. We just need to modify a few fields to make it work with each STM32, which is pretty nice !

### Makefile

Finally, I prepared a generic [makefile](#makefile) which will save our lives and make the journey way easier !

But hold on. What is a makefile ? And what the hell is a compiler ?

When you program, you write your code in a language we, human (not all, but some) can understand, like C or C++. However, computers doesn't understand these languages and we need to translate the code for them. Guess what, that's exactly what compilers do.

Of course we can use compilers in a terminal and write every command with all the flags, manually. Each time. And of course we don't want to do it. That's why makefile exists. We write everything once and for all in a document named (guess what) makefile (no way). This way, we can create and use lot easier commands.

Making a makefile is an art in its own right and it can be hard, especially for beginners. That's why I give you the makefile I use which is generic enough to be used without understanding anything about it. However, learn how to make a makefile is great. That's why I made a bonus complete "tutorial" to explain how I created the one we will use !

Now that you've got everything you need, let's turn it interesting...

# Organize our work

To make it work in the first hand, we need to create a new project (a simple folder) and store everything in the right space. Indeed I created and respected a few rules to stay organized but feel free to respect it to the letter, change ome rules or make your own rules ! However, if you want to create your own rules, be sure to understand how to create a makefile.

## My rules

As I said, I created my own set of rules especially for the project tree derived from STM32CubeIDE. I divided my projects in a few parts, every part being a folder :

- core : contains every core features related to the STM32 (GPIO, UART, timers, interrupts, SPI, I2C...)
	- inc : contains the header files (includes, i.e. .h and/or .hpp) of the core features
	- src : contains the source files (.c and/or .cpp) of the core features
	- startup : contains the startup file and linker script of the STM32
	- cmsis : contains every headers of the CMSIS and Device header files.
- drivers : contains every software module to drive other electronic components (from a low level perspective)
- lib : contains every other software components (from a high level perspective)

To better understand how I manage my projects, here some other generic rules I use:

- every module/folder (except inc, src and startup) can contain a submodule/subfolder being a library (ex : core/gpio for gpio features, or one library for each components in the drivers folder)
- every '.h' and '.hpp' files are stored in a 'inc' folder
- every '.c' and '.cpp' files are stored in a 'src' folder
- every folder and file names are in lowercase as it's easier to travel through in a terminal
- To avoid multiple header inclusions, I use the following syntax :
	- in headername.h :

```
#ifndef __HEADERNAME_H__
#define __HEADERNAME_H__

...

#endif

```

It make it clearer for me and seperated these define from other defines

With all these (useless ?) information, let's create this damn project !

## Create the project

Create where you want a folder with the name of your choice. Put inside the makefile, create a core folder and put somewhere inside the header, startup and linker files (in accordance with my rules if you want to follow them).

To complete the project tree with the bare minimum, add both main.h file and main.c files inside the core folder.

# Configuration and programming

## Configure your linke script

The first thing we need to do is to tell the linker the lenght of both the FLASH and the RAM memory. Indeed, every STM32 have the same address for both FLASH and RAM but the size may change.

You can find FLASH and RAM length in the STM32 datasheet. In the contents, find Embedded Flash Memory and Embedded SRAM, points 3.4 and 3.5 :

<!-- Add photo of the contents -->

Then, go to each section to get the information

<!-- Add photo of FLASH and RAM -->

As you can see, the STM32G474RE has 512Kbytes of FLASH and 96Kbytes of SRAM (SRAM1 + SRAM2 = 80 + 16 = 96).

*** Be careful, we are looking for SRAM, not CCM SRAM ***



# Bonus - Understand the makefile