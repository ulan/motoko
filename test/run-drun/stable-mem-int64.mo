import P "mo:⛔";
import StableMemory "stable-mem/StableMemory";
actor {

  stable var n : Nat32 = 0;
  assert (n == StableMemory.size());

  func valOfNat32(n : Nat32) : Int64 { P.intToInt64(P.nat32ToNat(n) : Int - 32768)};
  let inc : Nat32 = 8;

  var i : Nat32 = 0;
  let max = n * 65536;
  while (i < max) {
    let v = valOfNat32(i);
    assert (StableMemory.loadInt64(i) == v);
    StableMemory.storeInt64(i, ^v);
    assert (StableMemory.loadInt64(i) == ^v);
    StableMemory.storeInt64(i, v);
    i += inc
  };

  system func preupgrade() {
    P.debugPrint("upgrading..." # debug_show n);
    let m = StableMemory.grow(1);

    assert (n == m);

    n += 1;

    P.debugPrint(debug_show {old = m; new = n; size = StableMemory.size()});

    assert (n == StableMemory.size());

    // check new page is clear
    var i : Nat32 = m * 65536;
    let max = i + 65536;
    while (i < max) {
      assert (StableMemory.loadInt64(i) == 0);
      StableMemory.storeInt64(i, valOfNat32(i));
      i += inc
    };

  };

  public func testBounds() : async () {
    if (n == 0) return;
    assert (n == StableMemory.size());
    P.debugPrint (debug_show {testBounds=n});
    // test bounds check
    var i : Nat32 = n * 65536 - 7;
    let max = i + 16;
    while (i < max) {
      try {
        await async {
          ignore StableMemory.loadInt64(i);
        };
        assert false;
      }
      catch e {
        assert P.errorCode e == #canister_error;
      };
      try {
        await async StableMemory.storeInt64(i, valOfNat32(i));
        assert false;
      }
      catch e {
        assert P.errorCode e == #canister_error;
      };
      i += 1;
    };
  };

  system func postupgrade() {
    P.debugPrint("...upgraded" # debug_show n);
  };

}

//SKIP run
//SKIP run-low
//SKIP run-ir
// too slow on ic-ref-run:
//SKIP comp-ref

//CALL upgrade ""
//CALL ingress testBounds "DIDL\x00\x00"
//CALL upgrade ""
//CALL ingress testBounds "DIDL\x00\x00"
//CALL upgrade ""
//CALL ingress testBounds "DIDL\x00\x00"
//CALL upgrade ""

