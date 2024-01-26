/*******************************************************************************
 * Copyright 2019-2021 Microchip FPGA Embedded Systems Solutions.
 *
 * SPDX-License-Identifier: MIT
 *
 * Application code running on U54_1
 *
 * Example project demonstrating the use of polled and interrupt driven
 * transmission and reception over MMUART. Please refer README.md in the root
 * folder of this example project
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include "mpfs_hal/mss_hal.h"
#include "drivers/mss/mss_mmuart/mss_uart.h"
#include "inc/common.h"

#define PRINT(S) string_init(&g_tmp_str, S); MSS_UART_polled_tx(&g_mss_uart1_lo, g_tmp_str.txt, g_tmp_str.len);


/******************************************************************************
 * Instruction message. This message will be transmitted over the UART when
 * the program starts.
 *****************************************************************************/

const uint8_t g_message1[] =
        "\r\n\r\n\r\n **** PolarFire SoC MSS MMUART example ****\r\n\r\n\r\n";

const uint8_t g_message2[] =
        "This program is run from u54_1\r\n\
        \r\n\
Type 0  Show hart 1 debug message\r\n\
Type 1  Show this menu\r\n\
Type 2  Send message using polled method\r\n\
Type 3  send message using interrupt method\r\n\
";

const uint8_t polled_message[] =
        "This message has been transmitted using polled method. \r\n";

const uint8_t intr_message[] =
        " This message has been transmitted using interrupt method. \r\n";


#define RX_BUFF_SIZE    64U
uint8_t g_rx_buff[RX_BUFF_SIZE] = { 0 };
volatile uint32_t count_sw_ints_h1 = 0U;
volatile uint8_t g_rx_size = 0U;
static volatile uint32_t irq_cnt = 0;

#define LINE_SIZE 128U
typedef struct {
    size_t size;
    size_t len;
    size_t cur;
    uint8_t txt[LINE_SIZE];
} string_t;

string_t g_line;
#define NUM_LINE_PARTS 5
string_t g_line_parts[NUM_LINE_PARTS];
string_t g_tmp_str;
string_t g_err_msg;

bool g_line_ready = false;
bool g_echo = true;

//#define INFOLEN 138U
//uint8_t g_print_line[INFOLEN];

void string_init(string_t *str, uint8_t ch_array[])
{
    str->size = sizeof(str->txt) - 1; // minus 1 accounts for null terminator
    str->len = 0U; // len is <= size < sizeof(txt)
    str->cur = 0U;
    for (int i=0; i < str->size; i++) {
        str->txt[i] = 0U;
    }
    int i = 0;
    for (i=0; i < str->size; i++) {
        if (ch_array[i] == 0U) break;
        str->txt[i] = ch_array[i];
    }
    str->len = i;
}


bool string_copy(string_t *dest, const string_t *src)
{
    string_init(dest, "");
    dest->len = (src->len <= dest->size) ? src->len : dest->size;
    int i = 0;
    for (; i <= dest->len; i++) {
        dest->txt[i] = src->txt[i];
    }
    dest->txt[i] = 0U;
    bool success = dest->len == src->len;
    return success;
}


size_t string_append_nchar(string_t *str, const uint8_t ch_array[], size_t n)
{
    if (str->len + n >= sizeof(str->txt) - 1) {
        return 0;
    }
    for (int i=0; i<n; i++) {
        str->txt[str->cur++] = ch_array[i];
    }
    str->len = str->cur;
    str->txt[str->len] = 0U;
    return n;
}


void string_rtrim(string_t *s)
{
    while (isspace(s->txt[s->len-1])) {
        s->len--;
        s->txt[s->len] = 0U;
    }
    s->cur = 0;
}


bool string_skip_spaces(string_t *str)
{
    while ((str->cur < str->len) && isspace(str->txt[str->cur])) {
        str->cur++;
    }
    return str->cur < str->len; // return true if line has more txt
}


size_t string_get_word(string_t *str, string_t *word)
{
    string_init(word, "");
    string_skip_spaces(str);
    while ((str->cur < str->len) && !isspace(str->txt[str->cur])) {
        string_append_nchar(word, &(str->txt[str->cur]), 1);
        str->cur++;
    }
    return word->len; // return true if word is not empty
}


void string_get_words(string_t *cmd_line, string_t parts[]) {
    string_rtrim(cmd_line);
    for (int i=0; i<NUM_LINE_PARTS; i++) {
        string_get_word(cmd_line, &parts[i]);
    }
}


size_t string_get_to_eoln(string_t *str, string_t *word)
{
    string_init(word, "");
    string_skip_spaces(str);
    while (str->cur < str->len) {
        string_append_nchar(word, &(str->txt[str->cur]), 1);
        str->cur++;
    }
    return word->len; // return true if word is not empty
}


bool string_in_list(const string_t *s, const uint8_t list[])
{
    if (s->len == 0) return false;
    return (NULL != strstr(list, s->txt));
}


void string_swap(string_t *s1, string_t *s2)
{
    size_t len = (s1->len > s2->len) ? s1->len : s2->len;
    uint8_t ch1;
    size_t tmp;

    tmp = s1->size;
    s1->size = s2->size;
    s2->size = tmp;

    tmp = s1->len;
    s1->len = s2->len;
    s2->len = tmp;

    s1->cur = 0U;
    s2->cur = 0U;

    for (int i=0; i<=len; i++) {
        ch1 = s1->txt[i];
        s1->txt[i] = s2->txt[i];
        s2->txt[i] = ch1;
    }
    return;
}


// =====================================================================
// PeekPokeLang (PPL)
// =====================================================================

/**
1 = (set) result = a op b
2 peek addr value
3 poke addr value

4 if a op b
5 elif a op b
6 else
7 end [if, while]
8 while



addr = 0x8000_0000
loop_cnt = 0
while loop_cnt < 1000
    peek addr value
    if i < 10
        va1ue = value + 1
    elif i < 100
        value = value + 10
    else
        value = value + 100
    end
    poke addr value
    addr = addr + 4
    loop_cnt = loop_cnt + 1
end while


addr = 0x8000_0000
loop_cnt = 0
while wtag1 loop_cnt < 1000
    peek addr value
    if iftag1 i < 10
        va1ue = value + 10
    else iftag1
        if iftag2 i < 100
            value = value + 100
        else iftag2
            if iftag3 i < 1000
                value = value + 1000
            else iftag3
                value = value + 10000
            end iftag3
         end iftag2
    end iftag1
    poke addr value
    addr = addr + 4
    loop_cnt = loop_cnt + 1
end wtag1


addr = 0x8000_0000
loop_cnt = 0
while wtag1 loop_cnt < 1000

    peek addr value
    if iftag1 i < 10
        va1ue = value + 10
    else iftag1
    if iftag2 i < 100
        value = value + 100
    else iftag2
    if iftag3 i < 1000
        value = value + 1000
    else iftag3
        value = value + 10000
    end iftag3
    end iftag2
    end iftag1
    poke addr value
    addr = addr + 4
    loop_cnt = loop_cnt + 1
end wtag1



// = (set) : 1, a, op, b, v
// peek    : 2, a,  -, -, v
// poke    : 3, a,  -, -, v
// while   : 4, a, op, b, L
// if      : 5, a, op, b, L
// else    : 6, -,  -, -, L
// end     : 6, -,  -, -, -
**/

#define NUM_INSTRUCTIONS 128
#define NUM_VARIABLES     64
#define NUM_TAGS          64
#define NAME_SIZE         12
typedef struct {
    uint32_t data1;
    uint32_t data2;
    uint8_t  opcode; // {cmd[7:4], op[3:0]}
    uint8_t  result_tag_addr;
    bool     data1_is_number;
    bool     data2_is_number;
} instr_t;

typedef struct {
    uint32_t val;
    uint8_t  name[NAME_SIZE];
} data_t;

typedef struct {
    uint32_t inst_i;
    uint8_t  tag_name[NAME_SIZE];
} tag_t;

typedef struct {
    uint8_t inst_i;
    uint8_t inst_len;
    uint8_t data_len;
    uint8_t tag_len;
    uint8_t unused_tag_i;
    instr_t inst_mem[NUM_INSTRUCTIONS];
    data_t  data_mem[NUM_VARIABLES];
    tag_t   tag_table[NUM_TAGS];
} ppl_t;

ppl_t   g_ppl_vm;


void ppl_reset(ppl_t *ppl_vm)
{
    ppl_vm->inst_i = 0;
    ppl_vm->inst_len = 0;
    ppl_vm->data_len = 0;
    ppl_vm->tag_len = 0;
}


uint32_t ppl_get_data_index(ppl_t *ppl_vm, string_t *name, bool *is_number)
{
    *is_number = name->len > 0U;
    if (*is_number) {
        for (int i = 0; i <  name->len; i++) {
            *is_number = isxdigit(name->txt[i]);
            if (!(*is_number)) break;
        }
    }
    if (*is_number) {
        uint32_t number = (uint32_t)strtol(name->txt, NULL, 16);
        return number;
    }

    int i = 1;
    for (; i < ppl_vm->data_len; i++) {
        if (string_in_list(name, ppl_vm->data_mem[i].name)) {
            break;
        }
    }
    if (i >= ppl_vm->data_len) i = 0;
    return i;
}


uint8_t ppl_get_tag_index(ppl_t *ppl_vm, string_t *tag_name)
{
    int i = 1;
    for (; i < ppl_vm->tag_len; i++) {
        if (string_in_list(tag_name, ppl_vm->tag_table[i].tag_name)) {
            break;
        }
        if (ppl_vm->tag_table[i].inst_i == 0U) {
            ppl_vm->unused_tag_i = i;
        }
    }
    if (i >= ppl_vm->tag_len) i = 0;
    return i;
}

uint8_t ppl_append_data(ppl_t *ppl_vm, string_t *data_name)
{
    uint8_t ii = ppl_vm->data_len;
    ppl_vm->data_mem[ii].val = 0U;
    strncpy(ppl_vm->data_mem[ii].name, data_name->txt, NAME_SIZE-1);
    ppl_vm->data_mem[ii].name[NAME_SIZE-1] = 0U;
    ppl_vm->data_len++;
    return ii;
}

void ppl_compute_data(ppl_t *ppl_vm, uint8_t result, uint8_t data1, uint8_t operation, uint8_t data2)
{
    return;
}

void ppl_add_tag(ppl_t *ppl_vm, string_t *tag_name)
{
    uint8_t ii = ppl_vm->tag_len;
    if (ppl_vm->unused_tag_i > 0 && ppl_vm->unused_tag_i < ppl_vm->tag_len) {
        ii =  ppl_vm->unused_tag_i;
    }
    ppl_vm->tag_table[ii].inst_i = ppl_vm->inst_i;
    strncpy(ppl_vm->tag_table[ii].tag_name, tag_name->txt, NAME_SIZE-1);
    ppl_vm->tag_table[ii].tag_name[NAME_SIZE-1] = 0U;
    ppl_vm->unused_tag_i = 0;
    if (ii == ppl_vm->tag_len) {
        ppl_vm->tag_len++;
    }
}


uint8_t ppl_remove_tag(ppl_t *ppl_vm, string_t *tag_name)
{
    uint8_t tag_index = ppl_get_tag_index(ppl_vm, tag_name);
    if (tag_index == ppl_vm->tag_len) {
        return 0;
    }
    ppl_vm->tag_table[tag_index].tag_name[0] = 0U;
    ppl_vm->tag_table[tag_index].inst_i = 0U;
    ppl_vm->unused_tag_i = tag_index;
    return tag_index;
}


uint8_t ppl_compile_line(ppl_t *ppl_vm, string_t *line, string_t *err_msg)
{
    uint8_t err_code = 0;
    string_get_words(line, g_line_parts);
    if (string_in_list(&g_line_parts[1], "=")) {
        // change from: v = a + b to: = v + a b
        string_swap(&g_line_parts[0], &g_line_parts[1]);
    }


    // v     = a + b
    // =     v a + b (swap)
    // while t i < 9
    // if    t i < 9
    // peek  a v
    // poke  a v
    // else  t
    // end   t

    uint8_t operation = 0U;
    if (string_in_list(&g_line_parts[3], "==")) {
        operation = 0x1;
    } else if (string_in_list(&g_line_parts[3], "<")) {
        operation = 0x2;
    } else if (string_in_list(&g_line_parts[3], ">")) {
        operation = 0x3;
    } else if (string_in_list(&g_line_parts[3], "<=")) {
        operation = 0x4;
    } else if (string_in_list(&g_line_parts[3], ">=")) {
        operation = 0x5;
    } else if (string_in_list(&g_line_parts[3], "!=")) {
        operation = 0x6;
    } else if (string_in_list(&g_line_parts[3], "+")) {
        operation = 0x7;
    } else if (string_in_list(&g_line_parts[3], "-")) {
        operation = 0x8;
    } else if (string_in_list(&g_line_parts[3], "*")) {
        operation = 0x9;
    } else if (string_in_list(&g_line_parts[3], "/")) {
        operation = 0xa;
    } else if (string_in_list(&g_line_parts[3], "&")) {
        operation = 0xb;
    } else if (string_in_list(&g_line_parts[3], "|")) {
        operation = 0xc;
    } else if (string_in_list(&g_line_parts[3], "~")) {
        operation = 0xd;
    } else if (string_in_list(&g_line_parts[3], "<<")) {
        operation = 0xe;
    } else if (string_in_list(&g_line_parts[3], ">>")) {
        operation = 0xf;
    }

    uint8_t opcode = 0U;
    bool result_is_tag = false;
    if (string_in_list(&g_line_parts[0], "=")) {
        opcode = 0x10 + operation;
     } else if (string_in_list(&g_line_parts[0], "peek")) {
        opcode = 0x20;
    } else if (string_in_list(&g_line_parts[0], "poke")) {
        opcode = 0x30;
    } else if (string_in_list(&g_line_parts[0], "while")) {
        opcode = 0x40 + operation;
        result_is_tag = true;
    } else if (string_in_list(&g_line_parts[0], "if")) {
        opcode = 0x50 + operation;
        result_is_tag = true;
    } else if (string_in_list(&g_line_parts[0], "else")) {
        opcode = 0x60;
        result_is_tag = true;
    } else if (string_in_list(&g_line_parts[0], "end")) {
        opcode = 0x70;
        result_is_tag = true;
    }

    bool data1_is_number = false;
    uint32_t data1 = ppl_get_data_index(ppl_vm, &g_line_parts[2], &data1_is_number);

    bool data2_is_number = false;
    uint32_t data2 = ppl_get_data_index(ppl_vm, &g_line_parts[4], &data2_is_number);

    uint8_t result_tag_addr = 0;
    if (result_is_tag) {
        result_tag_addr = ppl_get_tag_index(ppl_vm, &g_line_parts[1]);
    } else {
        bool result_is_number = false;
        result_tag_addr = (uint8_t)ppl_get_data_index(ppl_vm, &g_line_parts[1], &result_is_number);
    }

    string_init(err_msg, "No errors detected\n\r");
    if (opcode == 0U) {
        err_code = 1; // Invalid opcode
        string_init(err_msg, "ERR 1: Invalid opcode\n\r");
    } else if (string_in_list(&g_line_parts[0], "= while if")) {
        if (g_line_parts[2].len == 0) {
            err_code = 2;
            string_init(err_msg, "ERR 2: Missing data 1 value or variable\n\r");
        } else if (data1 == 0 && !data1_is_number) {
            err_code = 3; // Invalid or undefined operand 1
            string_init(err_msg, "ERR 3: Undefined data 1 value variable\n\r");
        } else if ((g_line_parts[3].len > 0) && (opcode & 0xF == 0)) {
            err_code = 4; // Invalid operator
            string_init(err_msg, "ERR 4. Invalid operator\n\r");
        } else if ((opcode & 0xF) && (data2 == 0U && !data2_is_number)) {
            err_code = 5; // Invalid or missing operand 2
            string_init(err_msg, "ERR  5: Invalid or missing operand 2\n\r");
        }  if (string_in_list(&g_line_parts[0], "if while")) {
            if (g_line_parts[1].len == 0) {
                err_code = 6;
                string_init(err_msg, "ERR 6: Missing tag\n\r");
            } else if (result_tag_addr != 0) {
                err_code = 7;
                string_init(err_msg, "ERR 7: Reusing active tag\n\r");
            }
        }
    } else if (string_in_list(&g_line_parts[0], "peek poke")) {
        if (result_tag_addr == 0) {
            err_code = 8; // Invalid address
            string_init(err_msg, "ERR  8: Invalid address\n\r");
        } else if (g_line_parts[2].len == 0) {
            err_code = 9; // Missing variable
            string_init(err_msg, "ERR 9: Missing variable\n\r");
        } else if (string_in_list(&g_line_parts[0], "poke") && data1 == 0) {
            err_code = 10; // undefined source variable
            string_init(err_msg, "ERR 10: Undefined source variable\n\r");
        }
    } else if (string_in_list(&g_line_parts[0], "else end")) {
        if (g_line_parts[1].len == 0) {
            err_code = 11;
            string_init(err_msg, "ERR 11: Missing tag\n\r");
        } else if (result_tag_addr == 0) {
            err_code = 12; // undefined tag
            string_init(err_msg, "ERR 12: Undefined tag\n\r");
        }
    }


    if (err_code == 0) {
        ppl_vm->inst_mem[ppl_vm->inst_i].opcode = opcode;
        ppl_vm->inst_mem[ppl_vm->inst_i].data1 = data1;
        ppl_vm->inst_mem[ppl_vm->inst_i].data2 = data2;
        ppl_vm->inst_mem[ppl_vm->inst_i].data1_is_number = data1_is_number;
        ppl_vm->inst_mem[ppl_vm->inst_i].data2_is_number = data2_is_number;
        ppl_vm->inst_mem[ppl_vm->inst_i].result_tag_addr = result_tag_addr;
        if (string_in_list(&g_line_parts[0], "=")) {
            if (result_tag_addr == 0) {
                result_tag_addr = ppl_append_data(ppl_vm, &g_line_parts[1]);
            }
            ppl_compute_data(ppl_vm, result_tag_addr, data1, operation, data2);
        } else if (string_in_list(&g_line_parts[0], "if while")) {
            ppl_add_tag(ppl_vm, &g_line_parts[1]);
        } else if (string_in_list(&g_line_parts[0], "end")) {
            ppl_remove_tag(ppl_vm, &g_line_parts[1]);
        }
    }

    return err_code;
}


// =====================================================================
// =====================================================================

void rx_append(void) {
    string_append_nchar(&g_line, g_rx_buff, g_rx_size);
    if (g_line.txt[g_line.len-1] == '\n' ||
        g_line.txt[g_line.len-1] == '\r' ) {
        g_line_ready = true;
    }
}


void rx_echo(void) {
    if (g_echo && g_rx_size) {
        if (g_rx_buff[g_rx_size-1] == '\n' || g_rx_buff[g_rx_size-1] == '\r') {
            MSS_UART_polled_tx(&g_mss_uart1_lo, "\r\n", 2);
        } else {
            MSS_UART_polled_tx(&g_mss_uart1_lo, &g_rx_buff[g_rx_size-1], 1);
        }
    }
}


/* This is the handler function for the UART RX interrupt.
 * In this example project UART0 local interrupt is enabled on hart0.
 */
void uart1_rx_handler(mss_uart_instance_t *this_uart) {
    static int prev_rx_size = 0;
    uint32_t hart_id = read_csr(mhartid);
    int8_t info_string[50];

    /* This will execute when interrupt from hart 1 is raised */
    g_rx_size = MSS_UART_get_rx(this_uart, g_rx_buff, sizeof(g_rx_buff));
    rx_echo();
    rx_append();
    irq_cnt++;
    // sprintf(info_string, "UART1 Interrupt count = 0x%x \r\n\r\n", irq_cnt);
    // MSS_UART_polled_tx(&g_mss_uart1_lo, info_string, strlen(info_string));
}


/* Main function for the hart1(U54 processor).
 * Application code running on hart1 is placed here.
 * MMUART1 local interrupt is enabled on hart1.
 * In the respective U54 harts, local interrupts of the corresponding MMUART
 * are enabled. e.g. in U54_1.c local interrupt of MMUART1 is enabled. */

void u54_1(void) {
    uint64_t mcycle_start = 0U;
    uint64_t mcycle_end = 0U;
    uint64_t delta_mcycle = 0U;
    uint64_t hartid = read_csr(mhartid);


    string_init(&g_line, "");

    clear_soft_interrupt();
    set_csr(mie, MIP_MSIP);

#if (IMAGE_LOADED_BY_BOOTLOADER == 0)

    /* Put this hart in WFI. */
    do
    {
        __asm("wfi");
    }while(0 == (read_csr(mip) & MIP_MSIP));

    /* The hart is now out of WFI, clear the SW interrupt. Here onwards the
     * application can enable and use any interrupts as required */

    clear_soft_interrupt();

#endif

    __enable_irq();

    /* Bring all the MMUARTs out of Reset */
    (void) mss_config_clk_rst(MSS_PERIPH_MMUART1, (uint8_t) 1, PERIPHERAL_ON);
    (void) mss_config_clk_rst(MSS_PERIPH_MMUART2, (uint8_t) 1, PERIPHERAL_ON);
    (void) mss_config_clk_rst(MSS_PERIPH_MMUART3, (uint8_t) 1, PERIPHERAL_ON);
    (void) mss_config_clk_rst(MSS_PERIPH_MMUART4, (uint8_t) 1, PERIPHERAL_ON);
    (void) mss_config_clk_rst(MSS_PERIPH_CFM, (uint8_t) 1, PERIPHERAL_ON);

    /* All clocks ON */

    MSS_UART_init(&g_mss_uart1_lo,
    MSS_UART_115200_BAUD,
    MSS_UART_DATA_8_BITS | MSS_UART_NO_PARITY | MSS_UART_ONE_STOP_BIT);
    MSS_UART_set_rx_handler(&g_mss_uart1_lo, uart1_rx_handler, MSS_UART_FIFO_SINGLE_BYTE);

    MSS_UART_enable_local_irq(&g_mss_uart1_lo);

    /* Demonstrating polled MMUART transmission */
    MSS_UART_polled_tx(&g_mss_uart1_lo,g_message1, sizeof(g_message1));

    /* Demonstrating interrupt method of transmission */
    MSS_UART_irq_tx(&g_mss_uart1_lo, g_message2, sizeof(g_message2));

    /* Makes sure that the previous interrupt based transmission is completed
     * Alternatively, you could register TX complete handler using
     * MSS_UART_set_tx_handler() */
    while (0u == MSS_UART_tx_complete(&g_mss_uart1_lo)) {
        ;
    }

    mcycle_start = readmcycle();
    while (1u) {
        if (g_line_ready) {
            g_line_ready = false;
            uint8_t err_code = ppl_compile_line(&g_ppl_vm, &g_line, &g_err_msg);
            MSS_UART_polled_tx(&g_mss_uart1_lo, g_err_msg.txt, g_err_msg.len);

            g_line.cur = 0U;
            string_get_words(&g_line, g_line_parts);
            if (string_in_list(&g_line_parts[1], "=")) {
                string_swap(&g_line_parts[0], &g_line_parts[1]);
            }
            string_init(&g_line, "");
            PRINT("PARTS: ")
            for (int i=0; i<NUM_LINE_PARTS; i++) {
                if (g_line_parts[i].len == 0) break;
                MSS_UART_polled_tx(&g_mss_uart1_lo, g_line_parts[i].txt, g_line_parts[i].len);
                MSS_UART_polled_tx(&g_mss_uart1_lo, ", ", 2);
            }
            MSS_UART_polled_tx(&g_mss_uart1_lo, "\r\n", 2);

//            switch (g_rx_buff[0u]) {
//
//            case '0':
//                mcycle_end = readmcycle();
//                delta_mcycle = mcycle_end - mcycle_start;
//                sprintf(info_string, "hart %ld, %ld delta_mcycle \r\n", hartid,
//                        delta_mcycle);
//                MSS_UART_polled_tx(&g_mss_uart1_lo, info_string,
//                        strlen(info_string));
//                break;
//            case '1':
//                /* show menu */
//                MSS_UART_irq_tx(&g_mss_uart1_lo, g_message2,
//                        sizeof(g_message2));
//                break;
//            case '2':
//
//                /* polled method of transmission */
//                MSS_UART_polled_tx(&g_mss_uart1_lo, polled_message,
//                        sizeof(polled_message));
//
//                break;
//            case '3':
//
//                /* interrupt method of transmission */
//                MSS_UART_irq_tx(&g_mss_uart1_lo, intr_message,
//                        sizeof(intr_message));
//                break;
//
//            default:
//                // MSS_UART_polled_tx(&g_mss_uart1_lo, g_rx_buff, g_rx_size);
//                break;
//            }
//
//            g_rx_size = 0u;
        }
    }
}

/* hart1 Software interrupt handler */

void Software_h1_IRQHandler(void) {
    uint64_t hart_id = read_csr(mhartid);
    count_sw_ints_h1++;
}
