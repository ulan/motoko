pub mod copying;
pub mod mark_compact;

#[cfg(feature = "ic")]
unsafe fn should_do_gc() -> bool {
    use crate::memory::ic::{HP, LAST_HP};
    use crate::types::Bytes;

    use core::cmp::{max, min};

    // A factor of last heap size. We allow at most this much allocation before doing GC.
    const HEAP_GROWTH_FACTOR: f64 = 1.5;

    // On small heaps `last_hp * HEAP_GROWTH_FACTOR` will be quite small. To avoid doing redundant
    // collections in such cases we only check `last_hp * HEAP_GROWTH_FACTOR` if at least this
    // much is allocated.
    const SMALL_HEAP_DELTA: Bytes<u64> = Bytes(10 * 1024 * 1024); // 10 MiB

    // Regardless of other parameters (`HEAP_GROWTH_FACTOR`, `SMALL_HEAP_DELTA`) we want to do GC
    // if `HP` is more than this amount.
    const MAX_HP_FOR_GC: u64 = 3 * 1024 * 1024 * 1024; // 3 GiB

    let heap_limit = min(
        max(
            (f64::from(LAST_HP) * HEAP_GROWTH_FACTOR) as u64,
            u64::from(LAST_HP) + SMALL_HEAP_DELTA.0,
        ),
        MAX_HP_FOR_GC,
    );

    u64::from(HP) >= heap_limit
}
