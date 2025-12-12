---
title: Flutter Riverpod 实战：如何优雅解决页面闪烁与数据刷新抖动
date: 2025-12-12 15:53:36
tags: [Flutter, Riverpod, 技术优化]
categories: 开发小记
cover: "/images/flutter-riverpod.svg"
---

在开发 Flutter 应用时，我们经常会遇到这样的 UX 痛点：
1.  **页面切换闪烁**：从详情页返回列表页，或者在 Tab 之间切换时，页面会短暂显示 Loading 圈，然后才显示数据。
2.  **刷新抖动**：当后台静默同步数据（如数据库更新、网络轮询）时，UI 会突然闪一下“空数据状态”，然后又恢复正常。

这些问题在使用了 **Riverpod**（特别是结合 `riverpod_generator`）时如果处理不当尤为常见。本文将通过一个实际的“运动仪表盘”案例，分享两个关键的优化技巧，助你打造丝般顺滑的用户体验。

## 场景描述

假设我们有一个 `WorkoutDataNotifier`，它负责计算用户的年度跑量。它依赖于底层的数据库记录流 `workoutRecordsProvider`。

原始代码可能长这样：

```dart
@riverpod
class WorkoutDataNotifier extends _$WorkoutDataNotifier {
  @override
  Future<WorkoutData> build() async {
    // 监听数据库记录数量的变化
    ref.watch(
      workoutRecordsProvider.select((async) => 
        async.maybeWhen(
          data: (records) => records.length, 
          orElse: () => 0 // ⚠️ 问题埋伏点
        )
      ),
    );
    
    return _fetchWorkoutData();
  }
}
```

这段代码看似逻辑正确，但在实际运行中却导致了严重的闪烁问题。

---

## 技巧一：巧用 `keepAlive` 拒绝重复加载

### 问题现象
默认情况下，使用 `@riverpod` 注解生成的 Provider 是 **AutoDispose** 的。这意味着当页面销毁（例如用户跳转到其他页面，或者 Tab 切换导致 Widget 被卸载）时，Provider 的状态会被立即销毁。

当你再次回到该页面时，Provider 会重新初始化，`build()` 方法重新执行，导致 UI 再次进入 `AsyncLoading` 状态，用户就会看到烦人的 Loading 圈。

### 解决方案
对于仪表盘、个人中心这类高频访问且数据相对稳定的页面，我们应该保持其状态。

将注解修改为：

```dart
// ❌ Before
@riverpod

// ✅ After
@Riverpod(keepAlive: true)
class WorkoutDataNotifier extends _$WorkoutDataNotifier { ... }
```

### 原理解析
`keepAlive: true` 告诉 Riverpod：“即使没有监听者（Listener）了，也请把我的状态保留在内存中。”这样下次进入页面时，数据是现成的，UI 可以立即渲染，实现了“秒开”体验。

---

## 技巧二：深入理解 `AsyncValue` 的状态保留机制

这是本文的重点。很多开发者在处理 `AsyncValue` 时习惯使用 `maybeWhen`，但这在处理“刷新”场景时往往是**数据抖动**的根源。

### 问题代码剖析

让我们回到这段代码：

```dart
ref.watch(
  workoutRecordsProvider.select((async) => 
    async.maybeWhen(
      data: (records) => records.length, 
      orElse: () => 0
    )
  ),
);
```

**发生了什么？**
当 `workoutRecordsProvider` 触发刷新（例如后台同步了新数据）时，它的状态流转是这样的：
1.  **当前状态**：`AsyncData(100条记录)`。
2.  **开始刷新**：状态变为 `AsyncLoading`（但在 Riverpod 2.x 中，它依然持有上一次的数据）。
3.  **刷新完成**：状态变为新的 `AsyncData(101条记录)`。

**Bug 的根源**：
`maybeWhen` 方法在处理 `AsyncLoading` 状态时，如果你没有显式定义 `loading` 回调，它会默认走 `orElse`。
于是，数据流变成了：**100 -> 0 (orElse) -> 101**。

对于 `WorkoutDataNotifier` 来说，它看到依赖的数据突然变成了 `0`，于是它可能会清空当前的计算结果。紧接着数据又回来了，它又重新计算。这就导致 UI 上出现了一瞬间的“内容消失”或“闪烁”。

### 优化方案：使用 `valueOrNull`

Riverpod 2.x 的 `AsyncValue` 有一个非常强大的特性：**在 Loading 状态下可以保留旧数据**。我们需要利用这一点：

```dart
// ✅ 优化后的代码
ref.watch(
  workoutRecordsProvider.select((async) => 
    // 即使正在 loading，valueOrNull 也能取到上一次的旧值
    async.valueOrNull?.length ?? 0
  ),
);
```

### 为什么这样就不闪了？

使用 `valueOrNull` 后，状态流转变成了：
1.  **刷新前**：`valueOrNull` 返回 100。
2.  **刷新中**：虽然状态是 `AsyncLoading`，但 `valueOrNull` **依然返回 100**（Previous Data）。
3.  **刷新后**：`valueOrNull` 返回 101。

数据流变成了 **100 -> 100 -> 101**。
由于中间状态没有发生数值变化（或者变化很平滑），`select` 甚至不会通知 `WorkoutDataNotifier` 进行不必要的重建。彻底消除了数据抖动。

---

## 技巧三：UI 层的 `skipLoadingOnRefresh`

除了 Provider 内部的优化，在 UI 层消费数据时，也有一个配套的小技巧。

```dart
// 在 Widget build 方法中
final asyncValue = ref.watch(workoutDataNotifierProvider);

return asyncValue.when(
  // ✅ 关键配置：刷新时跳过 Loading 状态
  skipLoadingOnRefresh: true, 
  
  data: (data) => buildDashboard(data),
  loading: () => const CircularProgressIndicator(),
  error: (e, s) => Text('Error: $e'),
);
```

设置 `skipLoadingOnRefresh: true` 后，当 Provider 在后台刷新数据时，UI 会继续展示旧数据（执行 `data` 分支），而不是跳回 `loading` 分支显示转圈。直到新数据准备好，UI 直接更新内容。这对于下拉刷新或后台静默同步的体验至关重要。

---

## 总结

要解决 Flutter Riverpod 应用中的闪烁问题，核心在于**“维护数据的连续性”**：

1.  **生命周期连续性**：使用 `@Riverpod(keepAlive: true)` 避免页面切换导致的状态销毁。
2.  **数据流连续性**：在 Provider 内部依赖其他流时，优先使用 `async.valueOrNull` 而非 `maybeWhen`，以利用 Riverpod 的“旧数据保留”机制，防止刷新时的中间态导致数据归零。
3.  **视觉连续性**：在 UI 层使用 `skipLoadingOnRefresh: true`，避免刷新时出现不必要的 Loading 遮罩。

掌握这三点，你的 Flutter 应用体验将提升一个台阶！
