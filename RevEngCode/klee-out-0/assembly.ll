; ModuleID = '/workspace/RevEngCode/combined.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [4 x i8] c"num\00", align 1, !dbg !0
@.str.1 = private unnamed_addr constant [9 x i8] c"r1 == r2\00", align 1, !dbg !7
@.str.2 = private unnamed_addr constant [32 x i8] c"/workspace/RevEngCode/harness.c\00", align 1, !dbg !12
@__PRETTY_FUNCTION__.main = private unnamed_addr constant [11 x i8] c"int main()\00", align 1, !dbg !17
@.str.3 = private unnamed_addr constant [8 x i8] c"IGNORED\00", align 1, !dbg !23
@.str.1.4 = private unnamed_addr constant [16 x i8] c"overshift error\00", align 1, !dbg !29
@.str.2.5 = private unnamed_addr constant [14 x i8] c"overshift.err\00", align 1, !dbg !34

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @count_bits_v1(i32 noundef %num) #0 !dbg !57 {
entry:
  %num.addr = alloca i32, align 4
  %count = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 %num, ptr %num.addr, align 4
  call void @llvm.dbg.declare(metadata ptr %num.addr, metadata !63, metadata !DIExpression()), !dbg !64
  call void @llvm.dbg.declare(metadata ptr %count, metadata !65, metadata !DIExpression()), !dbg !66
  store i32 0, ptr %count, align 4, !dbg !66
  call void @llvm.dbg.declare(metadata ptr %i, metadata !67, metadata !DIExpression()), !dbg !69
  store i32 0, ptr %i, align 4, !dbg !69
  br label %for.cond, !dbg !70

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, ptr %i, align 4, !dbg !71
  %cmp = icmp slt i32 %0, 32, !dbg !73
  br i1 %cmp, label %for.body, label %for.end, !dbg !74

for.body:                                         ; preds = %for.cond
  %1 = load i32, ptr %num.addr, align 4, !dbg !75
  %2 = load i32, ptr %i, align 4, !dbg !78
  %int_cast_to_i64 = zext i32 %2 to i64, !dbg !79
  call void @klee_overshift_check(i64 32, i64 %int_cast_to_i64), !dbg !79
  %shr = ashr i32 %1, %2, !dbg !79, !klee.check.shift !80
  %and = and i32 %shr, 1, !dbg !81
  %tobool = icmp ne i32 %and, 0, !dbg !81
  br i1 %tobool, label %if.then, label %if.end, !dbg !82

if.then:                                          ; preds = %for.body
  %3 = load i32, ptr %count, align 4, !dbg !83
  %inc = add nsw i32 %3, 1, !dbg !83
  store i32 %inc, ptr %count, align 4, !dbg !83
  br label %if.end, !dbg !84

if.end:                                           ; preds = %if.then, %for.body
  br label %for.inc, !dbg !85

for.inc:                                          ; preds = %if.end
  %4 = load i32, ptr %i, align 4, !dbg !86
  %inc1 = add nsw i32 %4, 1, !dbg !86
  store i32 %inc1, ptr %i, align 4, !dbg !86
  br label %for.cond, !dbg !87, !llvm.loop !88

for.end:                                          ; preds = %for.cond
  %5 = load i32, ptr %count, align 4, !dbg !91
  ret i32 %5, !dbg !92
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @count_bits_v2(i32 noundef %num) #0 !dbg !93 {
entry:
  %num.addr = alloca i32, align 4
  %count = alloca i32, align 4
  store i32 %num, ptr %num.addr, align 4
  call void @llvm.dbg.declare(metadata ptr %num.addr, metadata !95, metadata !DIExpression()), !dbg !96
  call void @llvm.dbg.declare(metadata ptr %count, metadata !97, metadata !DIExpression()), !dbg !98
  store i32 0, ptr %count, align 4, !dbg !98
  br label %while.cond, !dbg !99

while.cond:                                       ; preds = %while.body, %entry
  %0 = load i32, ptr %num.addr, align 4, !dbg !100
  %tobool = icmp ne i32 %0, 0, !dbg !99
  br i1 %tobool, label %while.body, label %while.end, !dbg !99

while.body:                                       ; preds = %while.cond
  %1 = load i32, ptr %num.addr, align 4, !dbg !101
  %sub = sub nsw i32 %1, 1, !dbg !103
  %2 = load i32, ptr %num.addr, align 4, !dbg !104
  %and = and i32 %2, %sub, !dbg !104
  store i32 %and, ptr %num.addr, align 4, !dbg !104
  %3 = load i32, ptr %count, align 4, !dbg !105
  %inc = add nsw i32 %3, 1, !dbg !105
  store i32 %inc, ptr %count, align 4, !dbg !105
  br label %while.cond, !dbg !99, !llvm.loop !106

while.end:                                        ; preds = %while.cond
  %4 = load i32, ptr %count, align 4, !dbg !108
  ret i32 %4, !dbg !109
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 !dbg !110 {
entry:
  %retval = alloca i32, align 4
  %num = alloca i32, align 4
  %r1 = alloca i32, align 4
  %r2 = alloca i32, align 4
  store i32 0, ptr %retval, align 4
  call void @llvm.dbg.declare(metadata ptr %num, metadata !113, metadata !DIExpression()), !dbg !114
  call void @klee_make_symbolic(ptr noundef %num, i64 noundef 4, ptr noundef @.str), !dbg !115
  call void @llvm.dbg.declare(metadata ptr %r1, metadata !116, metadata !DIExpression()), !dbg !117
  %0 = load i32, ptr %num, align 4, !dbg !118
  %call = call i32 @count_bits_v1(i32 noundef %0), !dbg !119
  store i32 %call, ptr %r1, align 4, !dbg !117
  call void @llvm.dbg.declare(metadata ptr %r2, metadata !120, metadata !DIExpression()), !dbg !121
  %1 = load i32, ptr %num, align 4, !dbg !122
  %call1 = call i32 @count_bits_v2(i32 noundef %1), !dbg !123
  store i32 %call1, ptr %r2, align 4, !dbg !121
  %2 = load i32, ptr %r1, align 4, !dbg !124
  %3 = load i32, ptr %r2, align 4, !dbg !124
  %cmp = icmp eq i32 %2, %3, !dbg !124
  br i1 %cmp, label %if.then, label %if.else, !dbg !127

if.then:                                          ; preds = %entry
  br label %if.end, !dbg !127

if.else:                                          ; preds = %entry
  call void @__assert_fail(ptr noundef @.str.1, ptr noundef @.str.2, i32 noundef 12, ptr noundef @__PRETTY_FUNCTION__.main) #6, !dbg !124
  unreachable, !dbg !124

if.end:                                           ; preds = %if.then
  ret i32 0, !dbg !128
}

declare void @klee_make_symbolic(ptr noundef, i64 noundef, ptr noundef) #2

; Function Attrs: noreturn nounwind
declare void @__assert_fail(ptr noundef, ptr noundef, i32 noundef, ptr noundef) #3

; Function Attrs: noinline nounwind uwtable
define dso_local void @klee_overshift_check(i64 noundef %bitWidth, i64 noundef %shift) #4 !dbg !129 {
entry:
  %bitWidth.addr = alloca i64, align 8
  %shift.addr = alloca i64, align 8
  store i64 %bitWidth, ptr %bitWidth.addr, align 8
  call void @llvm.dbg.declare(metadata ptr %bitWidth.addr, metadata !133, metadata !DIExpression()), !dbg !134
  store i64 %shift, ptr %shift.addr, align 8
  call void @llvm.dbg.declare(metadata ptr %shift.addr, metadata !135, metadata !DIExpression()), !dbg !136
  %0 = load i64, ptr %shift.addr, align 8, !dbg !137
  %1 = load i64, ptr %bitWidth.addr, align 8, !dbg !139
  %cmp = icmp uge i64 %0, %1, !dbg !140
  br i1 %cmp, label %if.then, label %if.end, !dbg !141

if.then:                                          ; preds = %entry
  call void @klee_report_error(ptr noundef @.str.3, i32 noundef 0, ptr noundef @.str.1.4, ptr noundef @.str.2.5) #7, !dbg !142
  unreachable, !dbg !142

if.end:                                           ; preds = %entry
  ret void, !dbg !144
}

; Function Attrs: noreturn
declare void @klee_report_error(ptr noundef, i32 noundef, ptr noundef, ptr noundef) #5

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { noreturn nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { noreturn "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { noreturn nounwind }
attributes #7 = { noreturn }

!llvm.dbg.cu = !{!39, !41, !43, !46}
!llvm.ident = !{!49, !49, !49, !49}
!llvm.module.flags = !{!50, !51, !52, !53, !54, !55, !56}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 9, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "/workspace/RevEngCode/harness.c", directory: "", checksumkind: CSK_MD5, checksum: "5e3573093e6abed35aa7c08760b5cb9a")
!3 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 32, elements: !5)
!4 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!5 = !{!6}
!6 = !DISubrange(count: 4)
!7 = !DIGlobalVariableExpression(var: !8, expr: !DIExpression())
!8 = distinct !DIGlobalVariable(scope: null, file: !2, line: 12, type: !9, isLocal: true, isDefinition: true)
!9 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 72, elements: !10)
!10 = !{!11}
!11 = !DISubrange(count: 9)
!12 = !DIGlobalVariableExpression(var: !13, expr: !DIExpression())
!13 = distinct !DIGlobalVariable(scope: null, file: !2, line: 12, type: !14, isLocal: true, isDefinition: true)
!14 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 256, elements: !15)
!15 = !{!16}
!16 = !DISubrange(count: 32)
!17 = !DIGlobalVariableExpression(var: !18, expr: !DIExpression())
!18 = distinct !DIGlobalVariable(scope: null, file: !2, line: 12, type: !19, isLocal: true, isDefinition: true)
!19 = !DICompositeType(tag: DW_TAG_array_type, baseType: !20, size: 88, elements: !21)
!20 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !4)
!21 = !{!22}
!22 = !DISubrange(count: 11)
!23 = !DIGlobalVariableExpression(var: !24, expr: !DIExpression())
!24 = distinct !DIGlobalVariable(scope: null, file: !25, line: 27, type: !26, isLocal: true, isDefinition: true)
!25 = !DIFile(filename: "klee_src/runtime/Intrinsic/klee_overshift_check.c", directory: "/tmp", checksumkind: CSK_MD5, checksum: "5666ed772284910b5d0f856859e4d123")
!26 = !DICompositeType(tag: DW_TAG_array_type, baseType: !20, size: 64, elements: !27)
!27 = !{!28}
!28 = !DISubrange(count: 8)
!29 = !DIGlobalVariableExpression(var: !30, expr: !DIExpression())
!30 = distinct !DIGlobalVariable(scope: null, file: !25, line: 27, type: !31, isLocal: true, isDefinition: true)
!31 = !DICompositeType(tag: DW_TAG_array_type, baseType: !20, size: 128, elements: !32)
!32 = !{!33}
!33 = !DISubrange(count: 16)
!34 = !DIGlobalVariableExpression(var: !35, expr: !DIExpression())
!35 = distinct !DIGlobalVariable(scope: null, file: !25, line: 27, type: !36, isLocal: true, isDefinition: true)
!36 = !DICompositeType(tag: DW_TAG_array_type, baseType: !20, size: 112, elements: !37)
!37 = !{!38}
!38 = !DISubrange(count: 14)
!39 = distinct !DICompileUnit(language: DW_LANG_C11, file: !40, producer: "clang version 16.0.6 (https://github.com/llvm/llvm-project.git 7cbf1a2591520c2491aa35339f227775f4d3adf6)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None)
!40 = !DIFile(filename: "/workspace/RevEngCode/functions/f.c", directory: "/home/klee", checksumkind: CSK_MD5, checksum: "3aee3dd0e00e80da21e0064f8ba97869")
!41 = distinct !DICompileUnit(language: DW_LANG_C11, file: !42, producer: "clang version 16.0.6 (https://github.com/llvm/llvm-project.git 7cbf1a2591520c2491aa35339f227775f4d3adf6)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None)
!42 = !DIFile(filename: "/workspace/RevEngCode/functions/f_prime.c", directory: "/home/klee", checksumkind: CSK_MD5, checksum: "3aeff70f8eb98f6c89f18f4995becc22")
!43 = distinct !DICompileUnit(language: DW_LANG_C11, file: !44, producer: "clang version 16.0.6 (https://github.com/llvm/llvm-project.git 7cbf1a2591520c2491aa35339f227775f4d3adf6)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !45, splitDebugInlining: false, nameTableKind: None)
!44 = !DIFile(filename: "/workspace/RevEngCode/harness.c", directory: "/home/klee", checksumkind: CSK_MD5, checksum: "5e3573093e6abed35aa7c08760b5cb9a")
!45 = !{!0, !7, !12, !17}
!46 = distinct !DICompileUnit(language: DW_LANG_C89, file: !47, producer: "clang version 16.0.6 (https://github.com/llvm/llvm-project.git 7cbf1a2591520c2491aa35339f227775f4d3adf6)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !48, splitDebugInlining: false, nameTableKind: None)
!47 = !DIFile(filename: "/tmp/klee_src/runtime/Intrinsic/klee_overshift_check.c", directory: "/tmp/klee_build160stp_z3/runtime/Intrinsic", checksumkind: CSK_MD5, checksum: "5666ed772284910b5d0f856859e4d123")
!48 = !{!23, !29, !34}
!49 = !{!"clang version 16.0.6 (https://github.com/llvm/llvm-project.git 7cbf1a2591520c2491aa35339f227775f4d3adf6)"}
!50 = !{i32 7, !"Dwarf Version", i32 5}
!51 = !{i32 2, !"Debug Info Version", i32 3}
!52 = !{i32 1, !"wchar_size", i32 4}
!53 = !{i32 8, !"PIC Level", i32 2}
!54 = !{i32 7, !"PIE Level", i32 2}
!55 = !{i32 7, !"uwtable", i32 2}
!56 = !{i32 7, !"frame-pointer", i32 2}
!57 = distinct !DISubprogram(name: "count_bits_v1", scope: !58, file: !58, line: 1, type: !59, scopeLine: 1, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !39, retainedNodes: !62)
!58 = !DIFile(filename: "/workspace/RevEngCode/functions/f.c", directory: "", checksumkind: CSK_MD5, checksum: "3aee3dd0e00e80da21e0064f8ba97869")
!59 = !DISubroutineType(types: !60)
!60 = !{!61, !61}
!61 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!62 = !{}
!63 = !DILocalVariable(name: "num", arg: 1, scope: !57, file: !58, line: 1, type: !61)
!64 = !DILocation(line: 1, column: 23, scope: !57)
!65 = !DILocalVariable(name: "count", scope: !57, file: !58, line: 2, type: !61)
!66 = !DILocation(line: 2, column: 9, scope: !57)
!67 = !DILocalVariable(name: "i", scope: !68, file: !58, line: 3, type: !61)
!68 = distinct !DILexicalBlock(scope: !57, file: !58, line: 3, column: 5)
!69 = !DILocation(line: 3, column: 14, scope: !68)
!70 = !DILocation(line: 3, column: 10, scope: !68)
!71 = !DILocation(line: 3, column: 21, scope: !72)
!72 = distinct !DILexicalBlock(scope: !68, file: !58, line: 3, column: 5)
!73 = !DILocation(line: 3, column: 23, scope: !72)
!74 = !DILocation(line: 3, column: 5, scope: !68)
!75 = !DILocation(line: 4, column: 14, scope: !76)
!76 = distinct !DILexicalBlock(scope: !77, file: !58, line: 4, column: 13)
!77 = distinct !DILexicalBlock(scope: !72, file: !58, line: 3, column: 34)
!78 = !DILocation(line: 4, column: 21, scope: !76)
!79 = !DILocation(line: 4, column: 18, scope: !76)
!80 = !{!"True"}
!81 = !DILocation(line: 4, column: 24, scope: !76)
!82 = !DILocation(line: 4, column: 13, scope: !77)
!83 = !DILocation(line: 4, column: 34, scope: !76)
!84 = !DILocation(line: 4, column: 29, scope: !76)
!85 = !DILocation(line: 5, column: 5, scope: !77)
!86 = !DILocation(line: 3, column: 30, scope: !72)
!87 = !DILocation(line: 3, column: 5, scope: !72)
!88 = distinct !{!88, !74, !89, !90}
!89 = !DILocation(line: 5, column: 5, scope: !68)
!90 = !{!"llvm.loop.mustprogress"}
!91 = !DILocation(line: 6, column: 12, scope: !57)
!92 = !DILocation(line: 6, column: 5, scope: !57)
!93 = distinct !DISubprogram(name: "count_bits_v2", scope: !94, file: !94, line: 1, type: !59, scopeLine: 1, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !41, retainedNodes: !62)
!94 = !DIFile(filename: "/workspace/RevEngCode/functions/f_prime.c", directory: "", checksumkind: CSK_MD5, checksum: "3aeff70f8eb98f6c89f18f4995becc22")
!95 = !DILocalVariable(name: "num", arg: 1, scope: !93, file: !94, line: 1, type: !61)
!96 = !DILocation(line: 1, column: 23, scope: !93)
!97 = !DILocalVariable(name: "count", scope: !93, file: !94, line: 2, type: !61)
!98 = !DILocation(line: 2, column: 9, scope: !93)
!99 = !DILocation(line: 3, column: 5, scope: !93)
!100 = !DILocation(line: 3, column: 12, scope: !93)
!101 = !DILocation(line: 4, column: 17, scope: !102)
!102 = distinct !DILexicalBlock(scope: !93, file: !94, line: 3, column: 17)
!103 = !DILocation(line: 4, column: 21, scope: !102)
!104 = !DILocation(line: 4, column: 13, scope: !102)
!105 = !DILocation(line: 5, column: 14, scope: !102)
!106 = distinct !{!106, !99, !107, !90}
!107 = !DILocation(line: 6, column: 5, scope: !93)
!108 = !DILocation(line: 7, column: 12, scope: !93)
!109 = !DILocation(line: 7, column: 5, scope: !93)
!110 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 7, type: !111, scopeLine: 7, spFlags: DISPFlagDefinition, unit: !43, retainedNodes: !62)
!111 = !DISubroutineType(types: !112)
!112 = !{!61}
!113 = !DILocalVariable(name: "num", scope: !110, file: !2, line: 8, type: !61)
!114 = !DILocation(line: 8, column: 9, scope: !110)
!115 = !DILocation(line: 9, column: 5, scope: !110)
!116 = !DILocalVariable(name: "r1", scope: !110, file: !2, line: 10, type: !61)
!117 = !DILocation(line: 10, column: 9, scope: !110)
!118 = !DILocation(line: 10, column: 28, scope: !110)
!119 = !DILocation(line: 10, column: 14, scope: !110)
!120 = !DILocalVariable(name: "r2", scope: !110, file: !2, line: 11, type: !61)
!121 = !DILocation(line: 11, column: 9, scope: !110)
!122 = !DILocation(line: 11, column: 28, scope: !110)
!123 = !DILocation(line: 11, column: 14, scope: !110)
!124 = !DILocation(line: 12, column: 5, scope: !125)
!125 = distinct !DILexicalBlock(scope: !126, file: !2, line: 12, column: 5)
!126 = distinct !DILexicalBlock(scope: !110, file: !2, line: 12, column: 5)
!127 = !DILocation(line: 12, column: 5, scope: !126)
!128 = !DILocation(line: 13, column: 5, scope: !110)
!129 = distinct !DISubprogram(name: "klee_overshift_check", scope: !25, file: !25, line: 20, type: !130, scopeLine: 20, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !46, retainedNodes: !62)
!130 = !DISubroutineType(types: !131)
!131 = !{null, !132, !132}
!132 = !DIBasicType(name: "unsigned long long", size: 64, encoding: DW_ATE_unsigned)
!133 = !DILocalVariable(name: "bitWidth", arg: 1, scope: !129, file: !25, line: 20, type: !132)
!134 = !DILocation(line: 20, column: 46, scope: !129)
!135 = !DILocalVariable(name: "shift", arg: 2, scope: !129, file: !25, line: 20, type: !132)
!136 = !DILocation(line: 20, column: 75, scope: !129)
!137 = !DILocation(line: 21, column: 7, scope: !138)
!138 = distinct !DILexicalBlock(scope: !129, file: !25, line: 21, column: 7)
!139 = !DILocation(line: 21, column: 16, scope: !138)
!140 = !DILocation(line: 21, column: 13, scope: !138)
!141 = !DILocation(line: 21, column: 7, scope: !129)
!142 = !DILocation(line: 27, column: 5, scope: !143)
!143 = distinct !DILexicalBlock(scope: !138, file: !25, line: 21, column: 26)
!144 = !DILocation(line: 29, column: 1, scope: !129)
