################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Utilities/stm32l0xx_nucleo.c 

OBJS += \
./Utilities/stm32l0xx_nucleo.o 

C_DEPS += \
./Utilities/stm32l0xx_nucleo.d 


# Each subdirectory must supply rules for building sources it contributes
Utilities/%.o: ../Utilities/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo $(PWD)
	arm-none-eabi-gcc -mcpu=cortex-m0plus -mthumb -mfloat-abi=soft -DSTM32 -DSTM32L0 -DSTM32L010RBTx -DNUCLEO_L010RB -DDEBUG -DSTM32L010xB -DUSE_HAL_DRIVER -I"/home/toni/workspac_ac6/blinking_led_with_button/HAL_Driver/Inc/Legacy" -I"/home/toni/workspac_ac6/blinking_led_with_button/Utilities" -I"/home/toni/workspac_ac6/blinking_led_with_button/inc" -I"/home/toni/workspac_ac6/blinking_led_with_button/CMSIS/device" -I"/home/toni/workspac_ac6/blinking_led_with_button/CMSIS/core" -I"/home/toni/workspac_ac6/blinking_led_with_button/HAL_Driver/Inc" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


