################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../startup/startup_stm32l010xb.s 

OBJS += \
./startup/startup_stm32l010xb.o 


# Each subdirectory must supply rules for building sources it contributes
startup/%.o: ../startup/%.s
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Assembler'
	@echo $(PWD)
	arm-none-eabi-as -mcpu=cortex-m0plus -mthumb -mfloat-abi=soft -I"/home/toni/workspac_ac6/drive_led_motor_with_button/HAL_Driver/Inc/Legacy" -I"/home/toni/workspac_ac6/drive_led_motor_with_button/Utilities" -I"/home/toni/workspac_ac6/drive_led_motor_with_button/inc" -I"/home/toni/workspac_ac6/drive_led_motor_with_button/CMSIS/device" -I"/home/toni/workspac_ac6/drive_led_motor_with_button/CMSIS/core" -I"/home/toni/workspac_ac6/drive_led_motor_with_button/HAL_Driver/Inc" -g -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


