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
	arm-none-eabi-as -mcpu=cortex-m0plus -mthumb -mfloat-abi=soft -I"C:/Users/User/workspace/hardware_management_software/HAL_Driver/Inc/Legacy" -I"C:/Users/User/workspace/hardware_management_software/Utilities" -I"C:/Users/User/workspace/hardware_management_software/inc" -I"C:/Users/User/workspace/hardware_management_software/CMSIS/device" -I"C:/Users/User/workspace/hardware_management_software/CMSIS/core" -I"C:/Users/User/workspace/hardware_management_software/HAL_Driver/Inc" -g -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


