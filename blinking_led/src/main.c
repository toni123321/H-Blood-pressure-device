/**
  ******************************************************************************
  * @file    main.c
  * @author  Ac6
  * @version V1.0
  * @date    01-December-2013
  * @brief   Default main function.
  ******************************************************************************
*/


#include "stm32l0xx.h"
#include "stm32l0xx_nucleo.h"
			
static GPIO_InitTypeDef  GPIO_Struct;

void GPIO_Init();
void LED_Toggle();
void SystemClock_Config(void);



int main(void)
{
	HAL_Init();

	SystemClock_Config();

	GPIO_Init();

	while(1)
	{
		LED_Toggle();
	}
}

void GPIO_Init()
{
	LED2_GPIO_CLK_ENABLE();

	/* -2- Configure IO in output push-pull mode to drive external LEDs */
	GPIO_Struct.Mode  = GPIO_MODE_OUTPUT_PP;
	GPIO_Struct.Pull  = GPIO_PULLUP;
	GPIO_Struct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;

	GPIO_Struct.Pin = LED2_PIN;
	HAL_GPIO_Init(LED2_GPIO_PORT, &GPIO_Struct);
}

void LED_Toggle()
{
	HAL_GPIO_WritePin(LED2_GPIO_PORT, LED2_PIN, GPIO_PIN_SET);
	HAL_Delay(100);
	HAL_GPIO_WritePin(LED2_GPIO_PORT, LED2_PIN, GPIO_PIN_RESET);
	HAL_Delay(100);
}

void SystemClock_Config(void)
{
	RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};
	RCC_OscInitTypeDef RCC_OscInitStruct = {0};

	/* Enable MSI Oscillator */
	RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_MSI;
	RCC_OscInitStruct.MSIState = RCC_MSI_ON;
	RCC_OscInitStruct.MSIClockRange = RCC_MSIRANGE_5;
	RCC_OscInitStruct.MSICalibrationValue=0x00;
	RCC_OscInitStruct.PLL.PLLState = RCC_PLL_NONE;
	if (HAL_RCC_OscConfig(&RCC_OscInitStruct)!= HAL_OK)
	{
		/* Initialization Error */
		while(1);
	}

	/* Select MSI as system clock source and configure the HCLK, PCLK1 and PCLK2
	     clocks dividers */
	RCC_ClkInitStruct.ClockType = (RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2);
	RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_MSI;
	RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
	RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
	RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;
	if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0)!= HAL_OK)
	{
		/* Initialization Error */
		while(1);
	}
	/* Enable Power Control clock */
	__HAL_RCC_PWR_CLK_ENABLE();

	/* The voltage scaling allows optimizing the power consumption when the device is
	     clocked below the maximum system frequency, to update the voltage scaling value
	     regarding system frequency refer to product datasheet.  */
	__HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE3);
}
