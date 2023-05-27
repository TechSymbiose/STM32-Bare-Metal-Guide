#include "gpio.h"

#define STM32G474xx
#include "stm32g4xx.h"

static inline void spin(volatile uint32_t count) {
  while (count--) asm("nop");
}

void gpioTogglePin()
{
	RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN ;
	GPIOA->MODER &= ~GPIO_MODER_MODE5_Msk ;
	GPIOA->MODER |= 0x1 << GPIO_MODER_MODE5_Pos ;

	for (;;)
	{
		GPIOA->ODR |= GPIO_ODR_OD5 ;
		spin(999999);
		GPIOA->ODR &= ~GPIO_ODR_OD5 ;
		spin(999999);
  }
}