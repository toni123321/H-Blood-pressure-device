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
#include <stdio.h>
#include <string.h>

void clock_init();

void SystemClock_Config(void);

void Error_Handler();

void adc_init();

void set_gpio_timers_pwm();

void set_timers_pwm();

void uart_init();

void uart_output();


#define  PERIOD_VALUE       (uint32_t)(20000 - 1) /*  */
#define  PULSE_VALUE       (uint32_t)(PERIOD_VALUE/2) /* */

#define ADC_CONVERTED_DATA_BUFFER_SIZE   ((uint32_t)  32)   /* Size of array aADCxConvertedData[] */


TIM_HandleTypeDef    TimHandle;
TIM_OC_InitTypeDef Config;

/* Counter Prescaler value */
uint32_t uhPrescalerValue = 0;

GPIO_InitTypeDef GPIO_Struct;
GPIO_InitTypeDef  GPIO_InitStruct;
UART_HandleTypeDef UartHandle;

ADC_HandleTypeDef             AdcHandle;

/* ADC channel configuration structure declaration */
ADC_ChannelConfTypeDef        sConfig;

/* Variable containing ADC conversions data */
static uint16_t   aADCxConvertedData[ADC_CONVERTED_DATA_BUFFER_SIZE];



int main(void)
{
	HAL_Init();
	SystemClock_Config();

	clock_init();
	adc_init();
	uart_init();
	set_timers_pwm();

	while(1)
	{
		char buffer[16];
		int j; // num can be managed by potentiometer to be in range (0, 4095)
		HAL_UART_Transmit(&UartHandle, (uint8_t*)buffer, sprintf(buffer, "%d\n", j), 500);

		j = HAL_ADC_GetValue(&AdcHandle);

		TIM2->CCR1 = (uint32_t)(PERIOD_VALUE*j/4095);
	}


}

void SystemClock_Config(void)
{
	RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};
	RCC_OscInitTypeDef RCC_OscInitStruct = {0};

	/* Enable MSI Oscillator */
	RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_MSI;
	RCC_OscInitStruct.MSIState = RCC_MSI_ON;
	RCC_OscInitStruct.MSIClockRange = RCC_MSIRANGE_6;
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

void Error_Handler()
{
	BSP_LED_On(LED2);
	printf("Error");
}

void clock_init()
{
	__HAL_RCC_GPIOA_CLK_ENABLE();
	__HAL_RCC_GPIOC_CLK_ENABLE();
	__HAL_RCC_GPIOE_CLK_ENABLE();
}

void uart_init()
{
	/* Enable USART clock */
	__HAL_RCC_USART2_CLK_ENABLE();

	UartHandle.Instance        = USART2;
	UartHandle.Init.BaudRate   = 9600;
	UartHandle.Init.WordLength = UART_WORDLENGTH_8B;
	UartHandle.Init.StopBits   = UART_STOPBITS_1;
	UartHandle.Init.Parity     = UART_PARITY_NONE;
	UartHandle.Init.HwFlowCtl  = UART_HWCONTROL_NONE;
	UartHandle.Init.Mode       = UART_MODE_TX_RX;
	HAL_UART_Init(&UartHandle);

	/*##-2- Configure peripheral GPIO ##########################################*/
	/* UART TX GPIO pin configuration  */
	GPIO_InitStruct.Pin       = GPIO_PIN_2;
	GPIO_InitStruct.Mode      = GPIO_MODE_AF_PP;
	GPIO_InitStruct.Pull      = GPIO_PULLUP;
	GPIO_InitStruct.Speed     = GPIO_SPEED_FREQ_VERY_HIGH;
	GPIO_InitStruct.Alternate = GPIO_AF4_USART2;
	HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

	/* UART RX GPIO pin configuration  */
	GPIO_InitStruct.Pin = GPIO_PIN_3;
	GPIO_InitStruct.Alternate = GPIO_AF4_USART2;

	HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

}

void adc_init()
{
	__ADC1_CLK_ENABLE();
	AdcHandle.Instance          = ADC1;
	if (HAL_ADC_DeInit(&AdcHandle) != HAL_OK)
	{
		/* ADC de-initialization Error */
		//Error_Handler();
	}

	AdcHandle.Init.ClockPrescaler        = ADC_CLOCK_SYNC_PCLK_DIV2;      /* Synchronous clock mode, input ADC clock with prscaler 2 */

	AdcHandle.Init.Resolution            = ADC_RESOLUTION_12B;            /* 12-bit resolution for converted data */
	AdcHandle.Init.DataAlign             = ADC_DATAALIGN_RIGHT;           /* Right-alignment for converted data */
	AdcHandle.Init.ScanConvMode          = ADC_SCAN_DIRECTION_FORWARD;    /* Sequencer disabled (ADC conversion on only 1 channel: channel set on rank 1) */
	AdcHandle.Init.LowPowerAutoPowerOff  = DISABLE;
	AdcHandle.Init.EOCSelection          = ADC_EOC_SINGLE_CONV;           /* EOC flag picked-up to indicate conversion end */
	AdcHandle.Init.LowPowerFrequencyMode = DISABLE;
	AdcHandle.Init.LowPowerAutoWait      = DISABLE;                       /* Auto-delayed conversion feature disabled */
	AdcHandle.Init.ContinuousConvMode    = ENABLE;                        /* Continuous mode enabled (automatic conversion restart after each conversion) */
	AdcHandle.Init.DiscontinuousConvMode = DISABLE;                       /* Parameter discarded because sequencer is disabled */
	AdcHandle.Init.ExternalTrigConv      = ADC_SOFTWARE_START;            /* Software start to trig the 1st conversion manually, without external event */
	AdcHandle.Init.ExternalTrigConvEdge  = ADC_EXTERNALTRIGCONVEDGE_NONE; /* Parameter discarded because software trigger chosen */
	AdcHandle.Init.DMAContinuousRequests = ENABLE;                        /* ADC DMA continuous request to match with DMA circular mode */
	AdcHandle.Init.Overrun               = ADC_OVR_DATA_OVERWRITTEN;      /* DR register is overwritten with the last conversion result in case of overrun */
	AdcHandle.Init.OversamplingMode      = DISABLE;                       /* No oversampling */
	AdcHandle.Init.SamplingTime          = ADC_SAMPLETIME_7CYCLES_5;

	/* Initialize ADC peripheral according to the passed parameters */
	if (HAL_ADC_Init(&AdcHandle) != HAL_OK)
	{
		Error_Handler();
	}


	/* ### - 2 - Start calibration ############################################ */
	if (HAL_ADCEx_Calibration_Start(&AdcHandle, ADC_SINGLE_ENDED) !=  HAL_OK)
	{
		Error_Handler();
	}

	/* ### - 3 - Channel configuration ######################################## */
	sConfig.Channel      = ADC_CHANNEL_1;               /* Channel to be converted */
	sConfig.Rank         = ADC_RANK_CHANNEL_NUMBER;
	if (HAL_ADC_ConfigChannel(&AdcHandle, &sConfig) != HAL_OK)
	{
		Error_Handler();
	}

	/* ### - 4 - Start conversion in DMA mode ################################# */
	if (HAL_ADC_Start_DMA(&AdcHandle,
			(uint32_t *)aADCxConvertedData,
			ADC_CONVERTED_DATA_BUFFER_SIZE
	) != HAL_OK)
	{
		Error_Handler();
	}
}

void set_gpio_timers_pwm()
{
	GPIO_Struct.Pin       = GPIO_PIN_0;
	GPIO_Struct.Mode      = GPIO_MODE_AF_PP;
	GPIO_Struct.Pull      = GPIO_PULLUP;
	GPIO_Struct.Speed     = GPIO_SPEED_FREQ_VERY_HIGH;
	GPIO_Struct.Alternate = GPIO_AF2_TIM2;
	HAL_GPIO_Init(GPIOA, &GPIO_Struct);
}

void set_timers_pwm()
{
	__HAL_RCC_TIM2_CLK_ENABLE();

	//uhPrescalerValue = (uint32_t)(SystemCoreClock / 200000) - 1;
	uhPrescalerValue = 0;

	TimHandle.Instance = TIM2;
	TimHandle.Init.Prescaler		 = uhPrescalerValue;
	TimHandle.Init.Period			 = PERIOD_VALUE;
	TimHandle.Init.ClockDivision     = TIM_CLOCKDIVISION_DIV1;
	TimHandle.Init.CounterMode       = TIM_COUNTERMODE_UP;

	if (HAL_TIM_PWM_Init(&TimHandle) != HAL_OK)
	{
		/* Initialization Error */
		Error_Handler();
	}

	/*##-2- Configure the PWM channels #########################################*/
	/* Common configuration for all channels */
	Config.OCMode       = TIM_OCMODE_PWM1;
	Config.OCPolarity   = TIM_OCPOLARITY_HIGH;
	Config.OCFastMode   = TIM_OCFAST_DISABLE;

	/* Set the pulse value for channel 1 */
	Config.Pulse = 0;
	if (HAL_TIM_PWM_ConfigChannel(&TimHandle, &Config, TIM_CHANNEL_1) != HAL_OK)
	{
		/* Configuration Error */
		Error_Handler();
	}

	/*##-3- Start PWM signals generation #######################################*/
	/* Start channel 1 */
	if (HAL_TIM_PWM_Start(&TimHandle, TIM_CHANNEL_1) != HAL_OK)
	{
		/* PWM Generation Error */
		Error_Handler();
	}

	set_gpio_timers_pwm();
}

void uart_output()
{

}
