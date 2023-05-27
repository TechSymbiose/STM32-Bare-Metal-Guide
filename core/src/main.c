#include "main.h"

#include "gpio.h"

int main(void) {

  gpioTogglePin() ;

  return 0;
}

extern "C" void SystemInit()
{  
}