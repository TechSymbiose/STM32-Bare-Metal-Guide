#include "main.h"

#include "gpio.h"

int main(void) {

  gpioToggleLed() ;

  return 0;
}

extern "C" void SystemInit()
{  
}