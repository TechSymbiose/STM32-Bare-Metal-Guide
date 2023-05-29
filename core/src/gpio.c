#include "gpio.h"

#define STM32G474xx // Define the STM32 used BEFORE INCLUDING THE LIBRARY
#include "stm32g4xx.h" // Include the STM32 library

// Define the spin (delay) function
static inline void spin(volatile uint32_t count)
{
  while (count--) asm("nop"); // Run the 'nop' assembler operation
}

void gpioToggleLed()
{
	RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN ; // Enable GPIOA

	// Set GPIOA to output mode
	GPIOA->MODER &= ~GPIO_MODER_MODE5_Msk ; // Reset the previous without touching other registers mode applying the mask
	GPIOA->MODER |= 0x1 << GPIO_MODER_MODE5_Pos ; // Set the register 5 (pin 5) to 01 (= output mode)

	for (;;) // Infinite loop
	{
		GPIOA->ODR |= GPIO_ODR_OD5 ; // Turn pin 5 of GPIOA on
		spin(999999) ; // Add some delay
		GPIOA->ODR &= ~GPIO_ODR_OD5 ; // Turn pin 5 of GPIOA off
		spin(999999) ; //Add some delay
  }
}