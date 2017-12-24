---
layout: post
title: "Calling Convention in x86 Assembly"
date: 2017-12-23 18-41-19 +0800
categories: ['Assembly']
tags: ['Assembly']
disqus_identifier: 24791077740614535757766520032384790733
---

<style>
img {
    height: 400px;
}
</style>

## Registers

Modern (i.e 386 and beyond) x86 processor have eight 32-bit general purpose registers, as decipted in following Figure. The register names are mostly hsitorical. For example, `EAX` used to be called accumulator since it was used to by a number of arithmetic operations, and `ECX` was known as the counter since it was used to hold a loop index. Whereas most of the registers have lost their special purposes in the modern insturction set, by convention, two are reserved for special purposes —the stack pointer (`ESP`) and the base pointer (`EBP`).

For the `EAX`, `EBX`, `ECX` and `EDX` registers, subsections may be used. For example, the least significant 2 bytes of `EAX` can be treated as a 16-bit register called `AX`. The least significant byte of `AX` can be used as a signle 8-bit reigster called `AL`, while the most siginificant byte of `AX` can be used as a single 8-bit register called `AH`. These names refer to the same physical register. When a two-byte quantity is placed into `DX`, the update affects the value of `DH`, `DL`, and `EDX`. These sub-registers are mainly hold-overs from older, 16-bit version of the instruction set. However, they are sometimes convenient when dealing with data that are samller than 32-bits (e.g. 1-byte ASCII characters).

When referring to registers in assembly languages, the names are not case-sensitive. For example, the names `EAX` and `eax` refer to the same register.

![x86 Registers]({{ site.baseurl }}/assets/images/x86-assembly/x86-registers.png)

## Calling Convention

To allow separate programmers to share code and develop libraries for use by many programs, and to simplify the use of subroutines in general, programmers typically adopt a common *calling convention*. The calling convention is a protocl about how to call and return from routines. For example, given a set of calling convention rules, a programmer need not examine the definition of a subroutine to determine how paramters should be passed to that subroutine. Furthermore, given a set of calling convention rules, high-level language compilers can be made to follow the rules, thus allowing hand-coded assembly language routines and high-level language routines to call one another.

In practice, many calling conventions are possible. We will use the widely used C language calling convention. Following this convention will allow you to write assembly language subroutine that are safely callable from C (and C++) code, and will also enable you to call C library funcitons from your assembly language code.

The C calling convention is based heavily on the use of the hardware-supported stack. It is based on the `push`, `pop`, `call` and `ret` instructions. Subroutine parameters are passed on the stack. Registers are saved on the stack, and local variables used by the subroutines are placed in memory on the stack. The vast majority of high-level procedural languages implemented on most processors have used similar calling conventions.

The calling convention is broken into two sets of rules. The fist set of rules is employed by the caller of the subroutine, and the second set of rule is observed by the writer of the subroutine (the callee. It should be emphasized that mistakes in the observance of these rules quickly result in fatal program errors since the stack will be left in an incosistent state; thus metriculous care should be used when implementing the call convention in your own subroutines.

![x86 Registers]({{ site.baseurl }}/assets/images/x86-assembly/stack-convention.png)

A good way to visualize the operation of the calling convention is to draw the contents of the nearby region of the stack during subroutine execution. The image above depicts the contents of the stack during the execution of a subroutine with three paramters and three local variables. The cells depicted in the stack are 32-bit wide memory locations, thus the memory addresses of the cells are 4 bytes apart. The first paramter resides at an offest of 8 bytes from the base pointer. Above the paramters on the stack (and below the base pointer), the `call` instruction place the return address, thus leading to an extra 4 bytes of offset from the base pointer to the first parameter. When the `ret` instruction is used to return from the subroutine, it will jump to the return address stored on the stack.

### Caller Rulers

To make a subrouting call, the caller should:

1. Before calling a subroutine, the caller should save the contents of certain registers that are designated *caller-saved*. The caller-saved register are EAX, ECX, EDX. Since the called subroutine is allowed to modify these registers, it the called relies on their values after the subroutine returns, the called must push the values in these registers onto the stack (so they can be restore after the subroutine returns).
1. To pass paramters to the subroutine, push them onto the stack before the call. The paramters should be pushed in inverted order (i.e. last paramter first). Since the stack grows down, the first paramter will be stored at the lowest address (this inversion of paramter was historically used to allow function to be passed a variable number of paramters).
1. To call the subroutine, use the `call` instruction. This instruction places the return address on top of the paramters on the stack, and branches to the subroutine code. This invokes the subroutine, which should follow the callee rules below.

After the subroutine returns (immediately following the `call` instruction), the caller can expect to find the return value of the subroutine in the register EAX. To restore the machine state, the called should:

1. Remove the parameters from stack. This restores the stack to its state before the call was performed.

1. Restore the contents of caller-saved register (EAX, ECX, EDX) by poping them off of the stack. The caller assume that no other registers were modified by the subroutine.

**Example**

The code below shows a function call that follows the caller rules. The caller is calling a function *_myFunc* that takes three paramters. First paramter is in EAX, the second paramter is the constant 216; the third paramter is in memory location *var*.

```asm
push [var] ; Push last parameter first
push 216   ; Push the second parameter
push eax   ; Push first parameter last

call _myFunc ; Call the function (assume C naming)

add esp, 12
```

Note that after the call returns, the caller cleans up the stack using the `add` instruction. We have 12 bytes (3 paramters * 4 bytes each) on the stack, and the stack grows down. Thus, to get rid of the paramters, we can simply add 12 to the stack pointer.

The result produced by *_myFunc* is now available for use in the register EAX. The values of the caller-saved register (ECX and EDX), may been changed. If the caller uses them after the call, it would have needed to save them on the stack before the call and restore them after it.

### Callee Rules

The definition of the subroutine should adhere to the following rules at the begining of the subroutine:

1. Push the value of EBP onto the stack, the the copy the value of ESP into EBP using the folowing instruction:

```assembly
push ebp
mov  ebp, esp
```

This initial action maintains the *base pointer*, EBP. The base pointer is used by convention as a point of reference for finding paramters and local variables on the stack. When a subroutine is executing, the base pointer holds a copy of the stack pointer vlaue from when subroutine started executing. Paramters and local variables will always be located at known, constant offsets aways from the base pointer value. We put the old base pointer value at the begining of the subroutine so that we can later restore the appropriate base pointer value for the caller when the subroutine returns. Remember, the caller is not expecting the subroutine to change the value of the base pointer. We then move the stack pointer into EBP to obtain our pointer of reference for accessing parameters and local variables.

1. Next, allocate local variables by making space on the stack. Recall, the stack grow down, so to make space on the top of the stack, the stack pointer should be decremented. The amount by which the stack pointer is decremented depends on the number and size of local variables needed. For example, if 3 local integers (4 bytes each) were required, the stack pointer would need to be decremented by 12 to make space for these local variables (i.e. `sub esp, 12`). As with paramters, local variables will be located at known offests from the base pointer.

3. Next, save the value of the *callee-saved* registers that will be used by the function. To save registers, push them onto the stack. The callee-saved registers are EBX, EDI, and ESI (ESP and EBP will also be preserved by the calling convention, but need not be pused on the stack during this stemp).

After these three action are performed, the body of the subroutine may proceed. When the subroutine is returns, it must follow these steps:

1. Leave the return value in EAX.

1. Restore the old values of any callee-saved registers (EDI and ESI) that were modified. The register contents are restored by popping them from the stack. The registers should be popped in the inverse order that they were pushed. 

1. Deallocate local variables. The obvious way to do this might be to add the appropriate value to the stack pointer (since the space was allocated by subtracting the needed amount from the stack poitner). In praticice, a less error-prone way to deallocate the variables is to move the value in the base pointer into the stack pointer: `mov esp, ebp`. This works because the base pointer always contains the value that the stack pointer contained immediately prior to the allocation of the local variables.

1. Immediately before returing, restore the caller's base ponter value by poping EBP off the stack. Recall that the first thing we did on entry to the subroutine was to push the base pointer to save its old value.

1. Finally, return to the caller by executing a `ret` instruction. This instruction will find and remove the approxiate return address from the stack.

Note that the callee's rules fall cleanly into two halves that are basically mirror images of one another. The first half of the rules apply to the begining of the function, and are commonly said to define the *prologue* to the function. The later half of the rules apply to the end of the function, and are thus commonly said to defined the *epilogue* of the function.

**Example**

Here is an example function definition that follow the callee rules:

```assembly
.486
.MODEL FLAT
.CODE
PUBLIC _myFunc
_myFunc PROC
  ; Subroutine Prologue
  push ebp     ; Save the old base pointer value.
  mov ebp, esp ; Set the new base pointer value.
  sub esp, 4   ; Make room for one 4-byte local variable.
  push edi     ; Save the values of registers that the function
  push esi     ; will modify. This function uses EDI and ESI.
  ; (no need to save EBX, EBP, or ESP)

  ; Subroutine Body
  mov eax, [ebp+8]   ; Move value of parameter 1 into EAX
  mov esi, [ebp+12]  ; Move value of parameter 2 into ESI
  mov edi, [ebp+16]  ; Move value of parameter 3 into EDI

  mov [ebp-4], edi   ; Move EDI into the local variable
  add [ebp-4], esi   ; Add ESI into the local variable
  add eax, [ebp-4]   ; Add the contents of the local variable
                     ; into EAX (final result)

  ; Subroutine Epilogue 
  pop esi      ; Recover register values
  pop  edi
  mov esp, ebp ; Deallocate local variables
  pop ebp ; Restore the caller's base pointer value
  ret
_myFunc ENDP
END
```

The subroutine prologue performs the standard actions of saving a snapshot of the stack pointer in EBP (the base pointer), allocating local variables by decremnting the stack pointer, and saving register values on the stack.

In the body of the subroutine we can see the use of the base pointer. Both paramters and local variables are located at constant offests from the base pointer for the duration of the subroutines execution. In particular, we notice that since paramters were placed onto the stack before the subroutine was called, they are always located below the base pointer (i.e. at higher addresses) on the stack. The first paramter to the subroutine can always be found at memory location [EBP+8], the second at [EBP+12], the third at [EBP+16]. Simillarly, since local variables are allocated after the base pointers is set, they always reside above the base pointer (i.e. at lower addresses) ont the stack. In particular, the first local variable is always located at [EBP-4], the second at [EBP-8], and so on. The conventional use of the base pointer allows us to quickly indentify the use of local variables and paramters within a function body.

The function epilogue is basically a mirror image of the function prologue. The caller's register values are recovered from the stack, the local variables are deallocated by resetting the stack pointer, the caller's bse pointer value is recovered, the the `ret` instruction is used to return the appropriate code location in the caller.

- - -

## References

1. [http://www.cs.virginia.edu/~evans/cs216/guides/x86.html](http://www.cs.virginia.edu/~evans/cs216/guides/x86.html)
1. [https://www.recurse.com/blog/7-understanding-c-by-learning-assembly](https://www.recurse.com/blog/7-understanding-c-by-learning-assembly)
