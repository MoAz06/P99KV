==============================================================================
00000000000036c0 <(anonymous namespace)::freq_probe((anonymous namespace)::Ctx&)>:
    36c0:	endbr64
    36c4:	rdtsc
    36c6:	mov    %rax,%rsi
    36c9:	shl    $0x20,%rdx
    36cd:	or     %rdx,%rsi
    36d0:	xor    %ecx,%ecx
    36d2:	nopl   (%rax)
    36d5:	data16 cs nopw 0x0(%rax,%rax,1)
    36e0:	mov    %rcx,%rax
    36e3:	add    $0x1,%rax
    36e7:	mov    %rax,%rcx
    36ea:	cmp    $0x2faf07f,%rax
    36f0:	jbe    36e0 <(anonymous namespace)::freq_probe((anonymous namespace)::Ctx&)+0x20>
    36f2:	rdtsc
    36f4:	shl    $0x20,%rdx
    36f8:	movq   $0x0,0x8(%rdi)
    3700:	or     %rdx,%rax
    3703:	mov    %rcx,0x10(%rdi)
    3707:	sub    %rsi,%rax
    370a:	mov    %rax,(%rdi)
    370d:	mov    %rdi,%rax
    3710:	ret
    3711:	nopl   0x0(%rax)
    3715:	data16 cs nopw 0x0(%rax,%rax,1)

==============================================================================
0000000000003720 <(anonymous namespace)::warmup((anonymous namespace)::Ctx&)>:
    3720:	push   %r12
    3722:	xor    %r12d,%r12d
    3725:	push   %rbp
    3726:	mov    %rdi,%rbp
    3729:	push   %rbx
    372a:	xor    %ebx,%ebx
    372c:	nopl   0x0(%rax)
    3730:	mov    0x50(%rbp),%rax
    3734:	mov    %rbp,%rdi
    3737:	mov    (%rax,%rbx,1),%rsi
    373b:	shl    $0x5,%rsi
    373f:	add    0x38(%rbp),%rsi
    3743:	call   7040 <KeyValueStore::get(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&) const>
    3748:	test   %rax,%rax
    374b:	je     3751 <(anonymous namespace)::warmup((anonymous namespace)::Ctx&)+0x31>
    374d:	add    0x8(%rax),%r12
    3751:	add    $0x8,%rbx
    3755:	cmp    $0x13880,%rbx
    375c:	jne    3730 <(anonymous namespace)::warmup((anonymous namespace)::Ctx&)+0x10>
    375e:	mov    %r12,%rax
    3761:	pop    %rbx
    3762:	pop    %rbp
    3763:	pop    %r12
    3765:	ret
    3766:	cs nopw 0x0(%rax,%rax,1)

==============================================================================
0000000000003770 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::NoClock>((anonymous namespace)::Ctx&)>:
    3770:	endbr64
    3774:	push   %r15
    3776:	push   %r14
    3778:	push   %r13
    377a:	push   %r12
    377c:	push   %rbp
    377d:	push   %rbx
    377e:	sub    $0x38,%rsp
    3782:	mov    0x80(%rsi),%r14
    3789:	mov    %rdi,0x28(%rsp)
    378e:	mov    %r14,0x8(%rsp)
    3793:	cmp    $0x30d40,%r14
    379a:	ja     3865 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::NoClock>((anonymous namespace)::Ctx&)+0xf5>
    37a0:	mov    0x50(%rsi),%rdx
    37a4:	mov    0x68(%rsi),%rax
    37a8:	mov    %rsi,%r12
    37ab:	xor    %ebx,%ebx
    37ad:	movq   $0x0,(%rsp)
    37b5:	mov    0x38(%rsi),%r13
    37b9:	mov    %rdx,0x18(%rsp)
    37be:	mov    %rax,0x10(%rsp)
    37c3:	lea    0x0(,%r14,8),%rax
    37cb:	mov    %rax,0x20(%rsp)
    37d0:	lea    (%rax,%rdx,1),%rbp
    37d4:	xor    %eax,%eax
    37d6:	cmpq   $0x0,0x8(%rsp)
    37dc:	je     3849 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::NoClock>((anonymous namespace)::Ctx&)+0xd9>
    37de:	mov    0x18(%rsp),%rcx
    37e3:	lea    (%rcx,%rax,8),%r15
    37e7:	nopw   0x0(%rax,%rax,1)
    37f0:	mov    (%r15),%rsi
    37f3:	mov    %r12,%rdi
    37f6:	shl    $0x5,%rsi
    37fa:	add    %r13,%rsi
    37fd:	call   7040 <KeyValueStore::get(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&) const>
    3802:	test   %rax,%rax
    3805:	je     380b <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::NoClock>((anonymous namespace)::Ctx&)+0x9b>
    3807:	add    0x8(%rax),%rbx
    380b:	add    $0x8,%r15
    380f:	cmp    %rbp,%r15
    3812:	jne    37f0 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::NoClock>((anonymous namespace)::Ctx&)+0x80>
    3814:	addq   $0x1,(%rsp)
    3819:	mov    0x10(%rsp),%rcx
    381e:	mov    (%rsp),%rax
    3822:	movq   $0x0,-0x8(%rcx,%rax,8)
    382b:	mov    %r14,%rax
    382e:	add    0x8(%rsp),%r14
    3833:	cmp    $0x30d40,%r14
    383a:	ja     386f <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::NoClock>((anonymous namespace)::Ctx&)+0xff>
    383c:	add    0x20(%rsp),%rbp
    3841:	cmpq   $0x0,0x8(%rsp)
    3847:	jne    37de <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::NoClock>((anonymous namespace)::Ctx&)+0x6e>
    3849:	addq   $0x1,(%rsp)
    384e:	mov    0x10(%rsp),%rcx
    3853:	mov    (%rsp),%rdx
    3857:	movq   $0x0,-0x8(%rcx,%rdx,8)
    3860:	jmp    37d6 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::NoClock>((anonymous namespace)::Ctx&)+0x66>
    3865:	movq   $0x0,(%rsp)
    386d:	xor    %ebx,%ebx
    386f:	mov    0x28(%rsp),%rax
    3874:	mov    (%rsp),%rcx
    3878:	movq   $0x0,(%rax)
    387f:	mov    %rcx,0x8(%rax)
    3883:	mov    %rbx,0x10(%rax)
    3887:	add    $0x38,%rsp
    388b:	pop    %rbx
    388c:	pop    %rbp
    388d:	pop    %r12
    388f:	pop    %r13
    3891:	pop    %r14
    3893:	pop    %r15
    3895:	ret
    3896:	cs nopw 0x0(%rax,%rax,1)

==============================================================================
00000000000038a0 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::NoClock, true>((anonymous namespace)::Ctx&)>:
    38a0:	endbr64
    38a4:	push   %r15
    38a6:	xor    %r15d,%r15d
    38a9:	push   %r14
    38ab:	push   %r13
    38ad:	push   %r12
    38af:	push   %rbp
    38b0:	mov    %rsi,%rbp
    38b3:	push   %rbx
    38b4:	xor    %ebx,%ebx
    38b6:	sub    $0x18,%rsp
    38ba:	mov    0x68(%rsi),%r13
    38be:	mov    0x50(%rsi),%r14
    38c2:	mov    %rdi,0x8(%rsp)
    38c7:	mov    0x38(%rsi),%r12
    38cb:	nopl   0x0(%rax,%rax,1)
    38d0:	mov    (%r14,%r15,8),%rsi
    38d4:	mov    %rbp,%rdi
    38d7:	shl    $0x5,%rsi
    38db:	add    %r12,%rsi
    38de:	call   7040 <KeyValueStore::get(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&) const>
    38e3:	test   %rax,%rax
    38e6:	je     38ec <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::NoClock, true>((anonymous namespace)::Ctx&)+0x4c>
    38e8:	add    0x8(%rax),%rbx
    38ec:	mov    %rbx,%rax
    38ef:	movq   $0x0,0x0(%r13,%r15,8)
    38f8:	add    $0x1,%r15
    38fc:	mov    %rax,%rbx
    38ff:	cmp    $0x30d40,%r15
    3906:	jne    38d0 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::NoClock, true>((anonymous namespace)::Ctx&)+0x30>
    3908:	mov    0x8(%rsp),%rax
    390d:	movdqa 0x4c3b(%rip),%xmm0        # 8550 <C.128.1+0x20>
    3915:	mov    %rbx,0x10(%rax)
    3919:	movups %xmm0,(%rax)
    391c:	add    $0x18,%rsp
    3920:	pop    %rbx
    3921:	pop    %rbp
    3922:	pop    %r12
    3924:	pop    %r13
    3926:	pop    %r14
    3928:	pop    %r15
    392a:	ret
    392b:	nopl   0x0(%rax,%rax,1)

==============================================================================
0000000000003930 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::TscClock>((anonymous namespace)::Ctx&)>:
    3930:	endbr64
    3934:	push   %r15
    3936:	mov    %rdi,%rax
    3939:	push   %r14
    393b:	push   %r13
    393d:	push   %r12
    393f:	push   %rbp
    3940:	push   %rbx
    3941:	sub    $0x48,%rsp
    3945:	mov    0x80(%rsi),%r8
    394c:	cmp    $0x30d40,%r8
    3953:	ja     3a61 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::TscClock>((anonymous namespace)::Ctx&)+0x131>
    3959:	mov    0x50(%rsi),%r11
    395d:	mov    0x68(%rsi),%rcx
    3961:	mov    %rdi,0x38(%rsp)
    3966:	mov    %rsi,%r13
    3969:	lea    0x0(,%r8,8),%r10
    3971:	mov    0x38(%rsi),%r14
    3975:	xor    %r15d,%r15d
    3978:	xor    %ebp,%ebp
    397a:	mov    %r10,0x28(%rsp)
    397f:	lea    (%r10,%r11,1),%r12
    3983:	xor    %esi,%esi
    3985:	mov    %rcx,0x20(%rsp)
    398a:	mov    %r8,%rcx
    398d:	mov    %r11,0x30(%rsp)
    3992:	xor    %r11d,%r11d
    3995:	data16 cs nopw 0x0(%rax,%rax,1)
    39a0:	rdtsc
    39a2:	mov    %rax,%rdi
    39a5:	shl    $0x20,%rdx
    39a9:	or     %rdx,%rdi
    39ac:	test   %r8,%r8
    39af:	je     3a0a <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::TscClock>((anonymous namespace)::Ctx&)+0xda>
    39b1:	mov    0x30(%rsp),%rax
    39b6:	mov    %r8,(%rsp)
    39ba:	mov    %rdi,0x10(%rsp)
    39bf:	mov    %rcx,0x18(%rsp)
    39c4:	lea    (%rax,%r11,8),%rbx
    39c8:	mov    %r15,0x8(%rsp)
    39cd:	mov    %rsi,%r15
    39d0:	mov    (%rbx),%rsi
    39d3:	mov    %r13,%rdi
    39d6:	shl    $0x5,%rsi
    39da:	add    %r14,%rsi
    39dd:	call   7040 <KeyValueStore::get(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&) const>
    39e2:	test   %rax,%rax
    39e5:	je     39eb <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::TscClock>((anonymous namespace)::Ctx&)+0xbb>
    39e7:	add    0x8(%rax),%rbp
    39eb:	add    $0x8,%rbx
    39ef:	cmp    %r12,%rbx
    39f2:	jne    39d0 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::TscClock>((anonymous namespace)::Ctx&)+0xa0>
    39f4:	mov    %r15,%rsi
    39f7:	mov    (%rsp),%r8
    39fb:	mov    0x8(%rsp),%r15
    3a00:	mov    0x10(%rsp),%rdi
    3a05:	mov    0x18(%rsp),%rcx
    3a0a:	rdtsc
    3a0c:	add    0x28(%rsp),%r12
    3a11:	shl    $0x20,%rdx
    3a15:	add    $0x1,%r15
    3a19:	mov    %rcx,%r11
    3a1c:	add    %r8,%rcx
    3a1f:	or     %rdx,%rax
    3a22:	mov    0x20(%rsp),%rdx
    3a27:	sub    %rdi,%rax
    3a2a:	mov    %rax,-0x8(%rdx,%r15,8)
    3a2f:	add    %rax,%rsi
    3a32:	cmp    $0x30d40,%rcx
    3a39:	jbe    39a0 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::TscClock>((anonymous namespace)::Ctx&)+0x70>
    3a3f:	mov    0x38(%rsp),%rax
    3a44:	mov    %rsi,%r9
    3a47:	mov    %r9,(%rax)
    3a4a:	mov    %r15,0x8(%rax)
    3a4e:	mov    %rbp,0x10(%rax)
    3a52:	add    $0x48,%rsp
    3a56:	pop    %rbx
    3a57:	pop    %rbp
    3a58:	pop    %r12
    3a5a:	pop    %r13
    3a5c:	pop    %r14
    3a5e:	pop    %r15
    3a60:	ret
    3a61:	xor    %r15d,%r15d
    3a64:	xor    %ebp,%ebp
    3a66:	xor    %r9d,%r9d
    3a69:	jmp    3a47 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::TscClock>((anonymous namespace)::Ctx&)+0x117>
    3a6b:	nopl   0x0(%rax,%rax,1)

==============================================================================
0000000000003a70 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::ChronoClock>((anonymous namespace)::Ctx&)>:
    3a70:	endbr64
    3a74:	push   %r15
    3a76:	mov    %rdi,%rax
    3a79:	push   %r14
    3a7b:	push   %r13
    3a7d:	push   %r12
    3a7f:	push   %rbp
    3a80:	push   %rbx
    3a81:	sub    $0x48,%rsp
    3a85:	mov    0x80(%rsi),%rdx
    3a8c:	cmp    $0x30d40,%rdx
    3a93:	ja     3b93 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::ChronoClock>((anonymous namespace)::Ctx&)+0x123>
    3a99:	mov    0x50(%rsi),%r9
    3a9d:	mov    0x68(%rsi),%rcx
    3aa1:	mov    %rdx,0x8(%rsp)
    3aa6:	mov    %rsi,%r12
    3aa9:	lea    0x0(,%rdx,8),%rdi
    3ab1:	xor    %r15d,%r15d
    3ab4:	xor    %ebx,%ebx
    3ab6:	mov    %rdx,%r14
    3ab9:	mov    %rcx,0x20(%rsp)
    3abe:	mov    0x38(%rsi),%r13
    3ac2:	lea    (%rdi,%r9,1),%rbp
    3ac6:	movq   $0x0,(%rsp)
    3ace:	movq   $0x0,0x18(%rsp)
    3ad7:	mov    %rdi,0x28(%rsp)
    3adc:	mov    %r9,0x30(%rsp)
    3ae1:	mov    %rax,0x38(%rsp)
    3ae6:	cs nopw 0x0(%rax,%rax,1)
    3af0:	call   2340 <std::chrono::_V2::steady_clock::now()@plt>
    3af5:	mov    %rax,0x10(%rsp)
    3afa:	cmpq   $0x0,0x8(%rsp)
    3b00:	je     3b34 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::ChronoClock>((anonymous namespace)::Ctx&)+0xc4>
    3b02:	mov    0x30(%rsp),%rax
    3b07:	lea    (%rax,%r15,8),%r15
    3b0b:	nopl   0x0(%rax,%rax,1)
    3b10:	mov    (%r15),%rsi
    3b13:	mov    %r12,%rdi
    3b16:	shl    $0x5,%rsi
    3b1a:	add    %r13,%rsi
    3b1d:	call   7040 <KeyValueStore::get(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&) const>
    3b22:	test   %rax,%rax
    3b25:	je     3b2b <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::ChronoClock>((anonymous namespace)::Ctx&)+0xbb>
    3b27:	add    0x8(%rax),%rbx
    3b2b:	add    $0x8,%r15
    3b2f:	cmp    %rbp,%r15
    3b32:	jne    3b10 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::ChronoClock>((anonymous namespace)::Ctx&)+0xa0>
    3b34:	call   2340 <std::chrono::_V2::steady_clock::now()@plt>
    3b39:	addq   $0x1,(%rsp)
    3b3e:	mov    0x20(%rsp),%rdx
    3b43:	mov    %r14,%r15
    3b46:	mov    (%rsp),%rcx
    3b4a:	sub    0x10(%rsp),%rax
    3b4f:	add    0x8(%rsp),%r14
    3b54:	add    %rax,0x18(%rsp)
    3b59:	mov    %rax,-0x8(%rdx,%rcx,8)
    3b5e:	add    0x28(%rsp),%rbp
    3b63:	cmp    $0x30d40,%r14
    3b6a:	jbe    3af0 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::ChronoClock>((anonymous namespace)::Ctx&)+0x80>
    3b6c:	mov    %rcx,%r8
    3b6f:	mov    0x38(%rsp),%rax
    3b74:	mov    0x18(%rsp),%rcx
    3b79:	mov    %rcx,(%rax)
    3b7c:	mov    %r8,0x8(%rax)
    3b80:	mov    %rbx,0x10(%rax)
    3b84:	add    $0x48,%rsp
    3b88:	pop    %rbx
    3b89:	pop    %rbp
    3b8a:	pop    %r12
    3b8c:	pop    %r13
    3b8e:	pop    %r14
    3b90:	pop    %r15
    3b92:	ret
    3b93:	xor    %r8d,%r8d
    3b96:	xor    %ebx,%ebx
    3b98:	xor    %ecx,%ecx
    3b9a:	jmp    3b79 <(anonymous namespace)::BlockResult (anonymous namespace)::batched<(anonymous namespace)::ChronoClock>((anonymous namespace)::Ctx&)+0x109>
    3b9c:	nopl   0x0(%rax)

==============================================================================
0000000000003ba0 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::TscpClock, false>((anonymous namespace)::Ctx&)>:
    3ba0:	endbr64
    3ba4:	push   %r15
    3ba6:	xor    %r15d,%r15d
    3ba9:	push   %r14
    3bab:	push   %r13
    3bad:	push   %r12
    3baf:	push   %rbp
    3bb0:	xor    %ebp,%ebp
    3bb2:	push   %rbx
    3bb3:	xor    %ebx,%ebx
    3bb5:	sub    $0x38,%rsp
    3bb9:	mov    %rdi,0x18(%rsp)
    3bbe:	mov    %fs:0x28,%r12
    3bc7:	mov    %r12,0x28(%rsp)
    3bcc:	mov    %rsi,%r12
    3bcf:	mov    0x68(%r12),%rax
    3bd4:	mov    0x50(%r12),%r13
    3bd9:	mov    %rax,0x8(%rsp)
    3bde:	mov    0x38(%r12),%rax
    3be3:	mov    %rax,0x10(%rsp)
    3be8:	nopl   0x0(%rax,%rax,1)
    3bf0:	rdtscp
    3bf3:	mov    %ecx,0x24(%rsp)
    3bf7:	mov    %rax,%r14
    3bfa:	shl    $0x20,%rdx
    3bfe:	or     %rdx,%r14
    3c01:	lfence
    3c04:	mov    0x0(%r13,%r15,8),%rsi
    3c09:	mov    %r12,%rdi
    3c0c:	shl    $0x5,%rsi
    3c10:	add    0x10(%rsp),%rsi
    3c15:	call   7040 <KeyValueStore::get(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&) const>
    3c1a:	mov    %rax,%rsi
    3c1d:	rdtscp
    3c20:	mov    %ecx,0x24(%rsp)
    3c24:	shl    $0x20,%rdx
    3c28:	or     %rdx,%rax
    3c2b:	mov    %rsi,%rdx
    3c2e:	lfence
    3c31:	test   %rdx,%rdx
    3c34:	je     3c3a <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::TscpClock, false>((anonymous namespace)::Ctx&)+0x9a>
    3c36:	add    0x8(%rdx),%rbp
    3c3a:	mov    0x8(%rsp),%rdi
    3c3f:	sub    %r14,%rax
    3c42:	add    %rax,%rbx
    3c45:	mov    %rax,(%rdi,%r15,8)
    3c49:	add    $0x1,%r15
    3c4d:	cmp    $0x30d40,%r15
    3c54:	jne    3bf0 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::TscpClock, false>((anonymous namespace)::Ctx&)+0x50>
    3c56:	mov    0x18(%rsp),%rax
    3c5b:	mov    %rbx,(%rax)
    3c5e:	movq   $0x30d40,0x8(%rax)
    3c66:	mov    %rbp,0x10(%rax)
    3c6a:	mov    0x28(%rsp),%rax
    3c6f:	sub    %fs:0x28,%rax
    3c78:	jne    3c8e <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::TscpClock, false>((anonymous namespace)::Ctx&)+0xee>
    3c7a:	mov    0x18(%rsp),%rax
    3c7f:	add    $0x38,%rsp
    3c83:	pop    %rbx
    3c84:	pop    %rbp
    3c85:	pop    %r12
    3c87:	pop    %r13
    3c89:	pop    %r14
    3c8b:	pop    %r15
    3c8d:	ret
    3c8e:	call   2300 <__stack_chk_fail@plt>
    3c93:	xchg   %ax,%ax
    3c95:	data16 cs nopw 0x0(%rax,%rax,1)

==============================================================================
0000000000003ca0 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::TscpClock, true>((anonymous namespace)::Ctx&)>:
    3ca0:	endbr64
    3ca4:	push   %r15
    3ca6:	xor    %r15d,%r15d
    3ca9:	push   %r14
    3cab:	push   %r13
    3cad:	push   %r12
    3caf:	push   %rbp
    3cb0:	xor    %ebp,%ebp
    3cb2:	push   %rbx
    3cb3:	xor    %ebx,%ebx
    3cb5:	sub    $0x38,%rsp
    3cb9:	mov    %rdi,0x18(%rsp)
    3cbe:	mov    %fs:0x28,%r12
    3cc7:	mov    %r12,0x28(%rsp)
    3ccc:	mov    %rsi,%r12
    3ccf:	mov    0x68(%r12),%rax
    3cd4:	mov    0x50(%r12),%r13
    3cd9:	mov    %rax,0x8(%rsp)
    3cde:	mov    0x38(%r12),%rax
    3ce3:	mov    %rax,0x10(%rsp)
    3ce8:	nopl   0x0(%rax,%rax,1)
    3cf0:	rdtscp
    3cf3:	mov    %ecx,0x24(%rsp)
    3cf7:	mov    %rax,%r14
    3cfa:	shl    $0x20,%rdx
    3cfe:	or     %rdx,%r14
    3d01:	lfence
    3d04:	mov    0x0(%r13,%r15,8),%rsi
    3d09:	mov    %r12,%rdi
    3d0c:	shl    $0x5,%rsi
    3d10:	add    0x10(%rsp),%rsi
    3d15:	call   7040 <KeyValueStore::get(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&) const>
    3d1a:	test   %rax,%rax
    3d1d:	je     3d23 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::TscpClock, true>((anonymous namespace)::Ctx&)+0x83>
    3d1f:	add    0x8(%rax),%rbx
    3d23:	rdtscp
    3d26:	mov    %ecx,0x24(%rsp)
    3d2a:	shl    $0x20,%rdx
    3d2e:	or     %rdx,%rax
    3d31:	sub    %r14,%rax
    3d34:	lfence
    3d37:	mov    0x8(%rsp),%rdi
    3d3c:	add    %rax,%rbp
    3d3f:	mov    %rax,(%rdi,%r15,8)
    3d43:	add    $0x1,%r15
    3d47:	cmp    $0x30d40,%r15
    3d4e:	jne    3cf0 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::TscpClock, true>((anonymous namespace)::Ctx&)+0x50>
    3d50:	mov    0x18(%rsp),%rax
    3d55:	mov    %rbp,(%rax)
    3d58:	movq   $0x30d40,0x8(%rax)
    3d60:	mov    %rbx,0x10(%rax)
    3d64:	mov    0x28(%rsp),%rax
    3d69:	sub    %fs:0x28,%rax
    3d72:	jne    3d88 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::TscpClock, true>((anonymous namespace)::Ctx&)+0xe8>
    3d74:	mov    0x18(%rsp),%rax
    3d79:	add    $0x38,%rsp
    3d7d:	pop    %rbx
    3d7e:	pop    %rbp
    3d7f:	pop    %r12
    3d81:	pop    %r13
    3d83:	pop    %r14
    3d85:	pop    %r15
    3d87:	ret
    3d88:	call   2300 <__stack_chk_fail@plt>
    3d8d:	nopl   (%rax)

==============================================================================
0000000000003d90 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::TscClock, false>((anonymous namespace)::Ctx&)>:
    3d90:	endbr64
    3d94:	push   %r15
    3d96:	xor    %r15d,%r15d
    3d99:	push   %r14
    3d9b:	push   %r13
    3d9d:	push   %r12
    3d9f:	mov    %rsi,%r12
    3da2:	push   %rbp
    3da3:	xor    %ebp,%ebp
    3da5:	push   %rbx
    3da6:	xor    %ebx,%ebx
    3da8:	sub    $0x28,%rsp
    3dac:	mov    0x68(%rsi),%rax
    3db0:	mov    0x50(%rsi),%r13
    3db4:	mov    %rdi,0x18(%rsp)
    3db9:	mov    %rax,0x8(%rsp)
    3dbe:	mov    0x38(%rsi),%rax
    3dc2:	mov    %rax,0x10(%rsp)
    3dc7:	nopw   0x0(%rax,%rax,1)
    3dd0:	rdtsc
    3dd2:	mov    %rax,%r14
    3dd5:	shl    $0x20,%rdx
    3dd9:	or     %rdx,%r14
    3ddc:	mov    0x0(%r13,%r15,8),%rsi
    3de1:	mov    %r12,%rdi
    3de4:	shl    $0x5,%rsi
    3de8:	add    0x10(%rsp),%rsi
    3ded:	call   7040 <KeyValueStore::get(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&) const>
    3df2:	mov    %rax,%rcx
    3df5:	rdtsc
    3df7:	shl    $0x20,%rdx
    3dfb:	or     %rdx,%rax
    3dfe:	mov    %rcx,%rdx
    3e01:	test   %rdx,%rdx
    3e04:	je     3e0a <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::TscClock, false>((anonymous namespace)::Ctx&)+0x7a>
    3e06:	add    0x8(%rdx),%rbp
    3e0a:	mov    0x8(%rsp),%rdi
    3e0f:	sub    %r14,%rax
    3e12:	add    %rax,%rbx
    3e15:	mov    %rax,(%rdi,%r15,8)
    3e19:	add    $0x1,%r15
    3e1d:	cmp    $0x30d40,%r15
    3e24:	jne    3dd0 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::TscClock, false>((anonymous namespace)::Ctx&)+0x40>
    3e26:	mov    0x18(%rsp),%rax
    3e2b:	mov    %rbx,(%rax)
    3e2e:	movq   $0x30d40,0x8(%rax)
    3e36:	mov    %rbp,0x10(%rax)
    3e3a:	add    $0x28,%rsp
    3e3e:	pop    %rbx
    3e3f:	pop    %rbp
    3e40:	pop    %r12
    3e42:	pop    %r13
    3e44:	pop    %r14
    3e46:	pop    %r15
    3e48:	ret
    3e49:	nopl   0x0(%rax)

==============================================================================
0000000000003e50 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::TscClock, true>((anonymous namespace)::Ctx&)>:
    3e50:	endbr64
    3e54:	push   %r15
    3e56:	xor    %r15d,%r15d
    3e59:	push   %r14
    3e5b:	push   %r13
    3e5d:	push   %r12
    3e5f:	mov    %rsi,%r12
    3e62:	push   %rbp
    3e63:	xor    %ebp,%ebp
    3e65:	push   %rbx
    3e66:	xor    %ebx,%ebx
    3e68:	sub    $0x28,%rsp
    3e6c:	mov    0x68(%rsi),%rax
    3e70:	mov    0x50(%rsi),%r13
    3e74:	mov    %rdi,0x18(%rsp)
    3e79:	mov    %rax,0x8(%rsp)
    3e7e:	mov    0x38(%rsi),%rax
    3e82:	mov    %rax,0x10(%rsp)
    3e87:	nopw   0x0(%rax,%rax,1)
    3e90:	rdtsc
    3e92:	mov    %rax,%r14
    3e95:	shl    $0x20,%rdx
    3e99:	or     %rdx,%r14
    3e9c:	mov    0x0(%r13,%r15,8),%rsi
    3ea1:	mov    %r12,%rdi
    3ea4:	shl    $0x5,%rsi
    3ea8:	add    0x10(%rsp),%rsi
    3ead:	call   7040 <KeyValueStore::get(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&) const>
    3eb2:	test   %rax,%rax
    3eb5:	je     3ebb <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::TscClock, true>((anonymous namespace)::Ctx&)+0x6b>
    3eb7:	add    0x8(%rax),%rbx
    3ebb:	rdtsc
    3ebd:	mov    0x8(%rsp),%rcx
    3ec2:	shl    $0x20,%rdx
    3ec6:	or     %rdx,%rax
    3ec9:	sub    %r14,%rax
    3ecc:	mov    %rax,(%rcx,%r15,8)
    3ed0:	add    $0x1,%r15
    3ed4:	add    %rax,%rbp
    3ed7:	cmp    $0x30d40,%r15
    3ede:	jne    3e90 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::TscClock, true>((anonymous namespace)::Ctx&)+0x40>
    3ee0:	mov    0x18(%rsp),%rax
    3ee5:	mov    %rbp,(%rax)
    3ee8:	movq   $0x30d40,0x8(%rax)
    3ef0:	mov    %rbx,0x10(%rax)
    3ef4:	add    $0x28,%rsp
    3ef8:	pop    %rbx
    3ef9:	pop    %rbp
    3efa:	pop    %r12
    3efc:	pop    %r13
    3efe:	pop    %r14
    3f00:	pop    %r15
    3f02:	ret
    3f03:	xchg   %ax,%ax
    3f05:	data16 cs nopw 0x0(%rax,%rax,1)

==============================================================================
0000000000003f10 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::ChronoClock, false>((anonymous namespace)::Ctx&)>:
    3f10:	endbr64
    3f14:	push   %r15
    3f16:	xor    %r15d,%r15d
    3f19:	push   %r14
    3f1b:	push   %r13
    3f1d:	push   %r12
    3f1f:	xor    %r12d,%r12d
    3f22:	push   %rbp
    3f23:	push   %rbx
    3f24:	xor    %ebx,%ebx
    3f26:	sub    $0x28,%rsp
    3f2a:	mov    0x68(%rsi),%rcx
    3f2e:	mov    0x38(%rsi),%rax
    3f32:	mov    %rdi,0x18(%rsp)
    3f37:	mov    0x50(%rsi),%r14
    3f3b:	mov    %rsi,0x10(%rsp)
    3f40:	mov    %rcx,(%rsp)
    3f44:	mov    %rax,0x8(%rsp)
    3f49:	nopl   0x0(%rax)
    3f50:	call   2340 <std::chrono::_V2::steady_clock::now()@plt>
    3f55:	mov    %rax,%rbp
    3f58:	mov    (%r14,%r15,8),%rsi
    3f5c:	mov    0x10(%rsp),%rdi
    3f61:	shl    $0x5,%rsi
    3f65:	add    0x8(%rsp),%rsi
    3f6a:	call   7040 <KeyValueStore::get(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&) const>
    3f6f:	mov    %rax,%r13
    3f72:	call   2340 <std::chrono::_V2::steady_clock::now()@plt>
    3f77:	mov    %rax,%rsi
    3f7a:	mov    %r13,%rax
    3f7d:	test   %rax,%rax
    3f80:	je     3f86 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::ChronoClock, false>((anonymous namespace)::Ctx&)+0x76>
    3f82:	add    0x8(%rax),%r12
    3f86:	mov    (%rsp),%rdx
    3f8a:	mov    %rsi,%rax
    3f8d:	sub    %rbp,%rax
    3f90:	mov    %rax,(%rdx,%r15,8)
    3f94:	add    $0x1,%r15
    3f98:	add    %rax,%rbx
    3f9b:	cmp    $0x30d40,%r15
    3fa2:	jne    3f50 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::ChronoClock, false>((anonymous namespace)::Ctx&)+0x40>
    3fa4:	mov    0x18(%rsp),%rax
    3fa9:	mov    %rbx,(%rax)
    3fac:	movq   $0x30d40,0x8(%rax)
    3fb4:	mov    %r12,0x10(%rax)
    3fb8:	add    $0x28,%rsp
    3fbc:	pop    %rbx
    3fbd:	pop    %rbp
    3fbe:	pop    %r12
    3fc0:	pop    %r13
    3fc2:	pop    %r14
    3fc4:	pop    %r15
    3fc6:	ret
    3fc7:	nopw   0x0(%rax,%rax,1)

==============================================================================
0000000000003fd0 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::ChronoClock, true>((anonymous namespace)::Ctx&)>:
    3fd0:	endbr64
    3fd4:	push   %r15
    3fd6:	push   %r14
    3fd8:	mov    %rsi,%r14
    3fdb:	push   %r13
    3fdd:	push   %r12
    3fdf:	xor    %r12d,%r12d
    3fe2:	push   %rbp
    3fe3:	xor    %ebp,%ebp
    3fe5:	push   %rbx
    3fe6:	xor    %ebx,%ebx
    3fe8:	sub    $0x28,%rsp
    3fec:	mov    0x68(%rsi),%rax
    3ff0:	mov    0x50(%rsi),%r15
    3ff4:	mov    %rdi,0x18(%rsp)
    3ff9:	mov    %rax,0x8(%rsp)
    3ffe:	mov    0x38(%rsi),%rax
    4002:	mov    %rax,0x10(%rsp)
    4007:	nopw   0x0(%rax,%rax,1)
    4010:	call   2340 <std::chrono::_V2::steady_clock::now()@plt>
    4015:	mov    %rax,%r13
    4018:	mov    (%r15,%rbp,8),%rsi
    401c:	mov    %r14,%rdi
    401f:	shl    $0x5,%rsi
    4023:	add    0x10(%rsp),%rsi
    4028:	call   7040 <KeyValueStore::get(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&) const>
    402d:	test   %rax,%rax
    4030:	je     4036 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::ChronoClock, true>((anonymous namespace)::Ctx&)+0x66>
    4032:	add    0x8(%rax),%rbx
    4036:	call   2340 <std::chrono::_V2::steady_clock::now()@plt>
    403b:	mov    0x8(%rsp),%rdx
    4040:	sub    %r13,%rax
    4043:	mov    %rax,(%rdx,%rbp,8)
    4047:	add    $0x1,%rbp
    404b:	add    %rax,%r12
    404e:	cmp    $0x30d40,%rbp
    4055:	jne    4010 <(anonymous namespace)::BlockResult (anonymous namespace)::per_op<(anonymous namespace)::ChronoClock, true>((anonymous namespace)::Ctx&)+0x40>
    4057:	mov    0x18(%rsp),%rax
    405c:	mov    %r12,(%rax)
    405f:	movq   $0x30d40,0x8(%rax)
    4067:	mov    %rbx,0x10(%rax)
    406b:	add    $0x28,%rsp
    406f:	pop    %rbx
    4070:	pop    %rbp
    4071:	pop    %r12
    4073:	pop    %r13
    4075:	pop    %r14
    4077:	pop    %r15
    4079:	ret
    407a:	nopw   0x0(%rax,%rax,1)
