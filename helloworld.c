#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xscugic.h"
#define XPAR_FABRIC_EXT_IRQ_INTR 61U
#define XPAR_FABRIC_EXT_IRQ_INTR1 62U
XScuGic InterruptController;
static XScuGic_Config *GicConfig;



void ExtIrq_Handler1(void *InstancePtr){
	xil_printf("BARRIER HIT\r\n");
}

void ExtIrq_Handler(void *InstancePtr)
{
	xil_printf("COIN HIT\r\n");
}

int SetUpInterruptSystem(XScuGic *XScuGicInstancePtr)
{
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler) XScuGic_InterruptHandler, XScuGicInstancePtr);
	Xil_ExceptionEnable();
	return XST_SUCCESS;
}
int interrupt_init1()
{
	int Status;

	Status = XScuGic_Connect(&InterruptController, 62U, (Xil_ExceptionHandler)ExtIrq_Handler1, (void *)NULL);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XScuGic_Enable(&InterruptController, 62U);

	return XST_SUCCESS;
}

int interrupt_init()
{
	int Status;

	GicConfig = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
	if (NULL == GicConfig) {
		return XST_FAILURE;
	}
	Status = XScuGic_CfgInitialize(&InterruptController, GicConfig, GicConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	Status = SetUpInterruptSystem(&InterruptController);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	Status = XScuGic_Connect(&InterruptController, XPAR_FABRIC_EXT_IRQ_INTR, (Xil_ExceptionHandler)ExtIrq_Handler, (void *)NULL);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XScuGic_Enable(&InterruptController, XPAR_FABRIC_EXT_IRQ_INTR);

	return XST_SUCCESS;
}

int main()
{
    init_platform();

    print("Hello World\n\r");

    interrupt_init();
    interrupt_init1();

    while(1);

    print("Successfully ran Hello World application");
    cleanup_platform();
    return 0;
}
