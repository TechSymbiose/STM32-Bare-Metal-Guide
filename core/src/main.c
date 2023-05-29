#include "main.h"

#include "gpio.h" // include our (basic) gpio library

int main(void) {

  gpioToggleLed() ;

  return 0;
}

// Define a empty SystemInit function
extern "C" void SystemInit()
{  
}