/*
 Hash Tries in ActorScript
 -------------------------

 Functional maps (and sets) whose representation is "canonical", and
 history independent.

 See this POPL 1989 paper (Section 6):
 - "Incremental computation via function caching", Pugh & Teitelbaum.
 - https://dl.acm.org/citation.cfm?id=75305
 - Public copy here: http://matthewhammer.org/courses/csci7000-s17/readings/Pugh89.pdf

 By contrast, other usual functional representations of maps (AVL
 Trees, Red-Black Trees) do not enjoy history independence, and are
 each more complex to implement (e.g., each requires "rebalancing";
 these trees never do).

 */

// Done:
//
//  - (hacky) type definition; XXX: need real sum types to clean it up
//  - find operation
//  - insert operation
//  - remove operation
//  - replace operation (remove+insert via a single traversal)
//  - basic encoding of sets, and some set operations
//  - basic tests (and primitive debugging) for set operations
//  - write trie operations that operate over pairs of tries:
//    for set union, difference and intersection.
//  - handle hash collisions gracefully using association list module

// TODO-Matthew:
//
//  - (more) regression tests for everything that is below
//
//  - adapt the path length of each subtree to its cardinality; avoid
//    needlessly long paths, or paths that are too short for their
//    subtree's size.
//
//  - iterator objects, for use in 'for ... in ...' patterns


// import List

// TEMP: A "bit string" as a linked list of bits:
type Bits = ?(Bool, Bits);

// TODO: Replace this definition WordX, for some X, once we have these types in AS.
type Hash = Bits;
//type Hash = Word16;
//type Hash = Word8;

// Uniform depth assumption:
//
// We make a simplifying assumption, for now: All defined paths in the
// trie have a uniform length, the same as the number of bits of a
// hash, starting at the LSB, that we use for indexing.
//
// - If the number is too low, our expected O(log n) bounds become
//   expected O(n).
//
// - If the number is too high, we waste constant factors for
//   representing small sets/maps.
//
// TODO: Make this more robust by making this number adaptive for each
// path, and based on the content of the trie along that path.
//
let HASH_BITS = 4;

type Key<K> = {
  // hash field: permits fast inequality checks, permits collisions;
  // (eventually: permits incremental growth of deeper trie paths)
  hash: Hash;
  // key field: for conservative equality checks, after equal hashes.
  key: K;
};

// Binary branch nodes
type Branch<K,V> = {
  left:Trie<K,V>;
  right:Trie<K,V>;
};
// Leaf nodes are association lists of `Key<K>`s
// Every key shares a common hash prefix, its trie path.
type Leaf<K,V> = {
  keyvals:List<(Key<K>,V)>;
};

// XXX: See AST-42
type Node<K,V> = {
  left:Trie<K,V>;
  right:Trie<K,V>;
  keyvals:List<(Key<K>,V)>;
};

type Trie<K,V> = ?Node<K,V>;

/* See AST-42 (sum types); we want this type definition instead:

 // Use a sum type (AST-42)
 type Trie<K,V>     = { #leaf : LeafNode<K,V>; #bin : BinNode<K,V>; #empty };
 type BinNode<K,V>  = { left:Trie<K,V>; right:Trie<K,V> };
 type LeafNode<K,V> = { key:K; val:V };

 */

let Trie = new {

  // XXX: until AST-42:
  func isNull<X>(x : ?X) : Bool {
    switch x {
    case null { true  };
    case (?_) { false };
    };
  };

  // XXX: until AST-42:
  func assertIsNull<X>(x : ?X) {
    switch x {
    case null { assert(true)  };
    case (?_) { assert(false) };
    };
  };

  // XXX: until AST-42:
  func makeEmpty<K,V>() : Trie<K,V>
    = null;

  // Note: More general version of this operation below, which tests for
  // "deep emptiness" (subtrees that have branching structure, but no
  // leaves; these can result from naive filtering operations, for
  // instance).
  //
  // // XXX: until AST-42:
  // func isEmpty<K,V>(t:Trie<K,V>) : Bool {
  //   switch t {
  //     case null { true  };
  //     case (?_) { false };
  //   };
  // };

  // XXX: until AST-42:
  func assertIsEmpty<K,V>(t : Trie<K,V>) {
    switch t {
    case null { assert(true)  };
    case (?_) { assert(false) };
    };
  };

  // XXX: until AST-42:
  func makeBin<K,V>(l:Trie<K,V>, r:Trie<K,V>) : Trie<K,V>  {
    ?(new {left=l; right=r; keyvals=null; })
  };

  // XXX: until AST-42:
  func isBin<K,V>(t:Trie<K,V>) : Bool {
    switch t {
    case null { false };
    case (?t_) {
	         switch (t_.keyvals) {
	         case null { true };
	         case _ { false };
	         };
	       };
    }
  };

  // XXX: until AST-42:
  func makeLeaf<K,V>(kvs:AssocList<Key<K>,V>) : Trie<K,V> {
    ?(new {left=null; right=null; keyvals=kvs })
  };

  // XXX: until AST-42:
  func matchLeaf<K,V>(t:Trie<K,V>) : ?List<(Key<K>,V)> {
    switch t {
    case null { null };
    case (?t_) {
	         switch (t_.keyvals) {
	         case (?keyvals) ?(?(keyvals));
	         case (_) null;
	         }
	       };
    }
  };

  // XXX: until AST-42:
  func isLeaf<K,V>(t:Trie<K,V>) : Bool {
    switch t {
    case null { false };
    case (?t_) {
	         switch (t_.keyvals) {
	         case null { false };
	         case _ { true };
	         }
	       };
    }
  };
  // XXX: until AST-42:
  func assertIsBin<K,V>(t : Trie<K,V>) {
    switch t {
    case null { assert(false) };
    case (?n) {
	         assertIsNull<((Key<K>,V),AssocList<Key<K>,V>)>(n.keyvals);
         };
    }
  };

  // XXX: until AST-42:
  func getLeafKey<K,V>(t : Node<K,V>) : Key<K> {
    assertIsNull<Node<K,V>>(t.left);
    assertIsNull<Node<K,V>>(t.right);
    switch (t.keyvals) {
    case (?((k,v),_)) { k };
    case (null) { /* ERROR */ getLeafKey<K,V>(t) };
    }
  };

  // XXX: this helper is an ugly hack; we need real sum types to avoid it, I think:
  func getLeafVal<K,V>(t : Node<K,V>) : V {
    assertIsNull<Node<K,V>>(t.left);
    assertIsNull<Node<K,V>>(t.right);
    switch (t.keyvals) {
    case (?((k,v),_)) { v };
    case null { /* ERROR */ getLeafVal<K,V>(t) };
    }
  };

  // TODO: Replace with bitwise operations on Words, once we have each of those in AS.
  // For now, we encode hashes as lists of booleans.
  func getHashBit(h:Hash, pos:Nat) : Bool {
    switch h {
    case null {
	         // XXX: Should be an error case; it shouldn't happen in our tests if we set them up right.
	         false
	       };
    case (?(b, h_)) {
	         if (pos == 0) { b }
	         else { getHashBit(h_, pos-1) }
	       };
    }
  };

  // Test if two lists of bits are equal.
  func hashEq(ha:Hash, hb:Hash) : Bool {
    switch (ha, hb) {
    case (null, null) true;
    case (null, _) false;
    case (_, null) false;
    case (?(bita, ha2), ?(bitb, hb2)) {
	         if (bita == bitb) { hashEq(ha2, hb2) }
	         else { false }
	       };
    }
  };

  // Equality function for two `Key<K>`s, in terms of equaltiy of `K`'s.
  func keyEq<K>(keq:(K,K) -> Bool) : ((Key<K>,Key<K>) -> Bool) = {
    func (key1:Key<K>, key2:Key<K>) : Bool =
      (hashEq(key1.hash, key2.hash) and keq(key1.key, key2.key))
  };

  // part of "public interface":
  func empty<K,V>() : Trie<K,V> = makeEmpty<K,V>();

  // helper function for constructing new paths of uniform length
  func buildNewPath<K,V>(bitpos:Nat, k:Key<K>, ov:?V) : Trie<K,V> {
    func rec(bitpos:Nat) : Trie<K,V> {
      if ( bitpos < HASH_BITS ) {
	      // create new bin node for this bit of the hash
	      let path = rec(bitpos+1);
	      let bit = getHashBit(k.hash, bitpos);
	      if (not bit) {
	        ?(new {left=path; right=null; keyvals=null})
	      }
	      else {
	        ?(new {left=null; right=path; keyvals=null})
	      }
      } else {
	      // create new leaf for (k,v) pair, if the value is non-null:
        switch ov {
          case null { ?(new {left=null; right=null; keyvals=null }) };
          case (?v) { ?(new {left=null; right=null; keyvals=?((k,v),null) }) };
        }
      }
    };
    rec(bitpos)
  };

  // replace the given key's value option with the given one, returning the previous one
  func replace<K,V>(t : Trie<K,V>, k:Key<K>, k_eq:(K,K)->Bool, v:?V) : (Trie<K,V>, ?V) {
    let key_eq = keyEq<K>(k_eq);
    // For `bitpos` in 0..HASH_BITS, walk the given trie and locate the given value `x`, if it exists.
    func rec(t : Trie<K,V>, bitpos:Nat) : (Trie<K,V>, ?V) {
      if ( bitpos < HASH_BITS ) {
	      switch t {
	      case null { (buildNewPath<K,V>(bitpos, k, v), null) };
	      case (?n) {
	             assertIsBin<K,V>(t);
	             let bit = getHashBit(k.hash, bitpos);
	             // rebuild either the left or right path with the inserted (k,v) pair
	             if (not bit) {
	               let (l, v_) = rec(n.left, bitpos+1);
	               (?(new {left=l; right=n.right; keyvals=null; }), v_)
	             }
	             else {
	               let (r, v_) = rec(n.right, bitpos+1);
	               (?(new {left=n.left; right=r; keyvals=null; }), v_)
	             }
	           };
        }
      } else {
	      // No more walking; we should be at a leaf now, by construction invariants.
	      switch t {
	      case null { (buildNewPath<K,V>(bitpos, k, v), null) };
	      case (?l) {
	             // Permit hash collisions by walking
               // a list/array of KV pairs in each leaf:
               let (kvs2, old_val) =
                 AssocList.replace<Key<K>,V>(l.keyvals, k, key_eq, v);
	             (?(new{left=null; right=null; keyvals=kvs2}), old_val)
	           };
	      }
      }
    };
    rec(t, 0)
  };

  // insert the given key's value in the trie; return the new trie
  func insert<K,V>(t : Trie<K,V>, k:Key<K>, k_eq:(K,K)->Bool, v:V) : (Trie<K,V>, ?V) {
    replace<K,V>(t, k, k_eq, ?v)
  };

  // remove the given key's value in the trie; return the new trie
  func remove<K,V>(t : Trie<K,V>, k:Key<K>, k_eq:(K,K)->Bool) : (Trie<K,V>, ?V) {
    replace<K,V>(t, k, k_eq, null)
  };

  // find the given key's value in the trie, or return null if nonexistent
  func find<K,V>(t : Trie<K,V>, k:Key<K>, k_eq:(K,K) -> Bool) : ?V {
    let key_eq = keyEq<K>(k_eq);
    // For `bitpos` in 0..HASH_BITS, walk the given trie and locate the given value `x`, if it exists.
    func rec(t : Trie<K,V>, bitpos:Nat) : ?V {
      if ( bitpos < HASH_BITS ) {
	      switch t {
	      case null {
	             // the trie may be "sparse" along paths leading to no keys, and may end early.
	             null
	           };
	      case (?n) {
	             assertIsBin<K,V>(t);
	             let bit = getHashBit(k.hash, bitpos);
	             if (not bit) { rec(n.left,  bitpos+1) }
	             else         { rec(n.right, bitpos+1) }
	           };
	      }
      } else {
	      // No more walking; we should be at a leaf now, by construction invariants.
	      switch t {
	      case null { null };
	      case (?l) {
	             // Permit hash collisions by walking a list/array of KV pairs in each leaf:
               AssocList.find<Key<K>,V>(l.keyvals, k, key_eq)
	           };
	      }
      }
    };
    rec(t, 0)
  };

  // merge tries, preferring the right trie where there are collisions
  // in common keys. note: the `disj` operation generalizes this `merge`
  // operation in various ways, and does not (in general) loose
  // information; this operation is a simpler, special case.
  func merge<K,V>(tl:Trie<K,V>, tr:Trie<K,V>, k_eq:(K,K)->Bool): Trie<K,V> {
    let key_eq = keyEq<K>(k_eq);
    func rec(tl:Trie<K,V>, tr:Trie<K,V>) : Trie<K,V> {
      switch (tl, tr) {
      case (null, _) { return tr };
      case (_, null) { return tl };
      case (?nl,?nr) {
             switch (isBin<K,V>(tl),
	                   isBin<K,V>(tr)) {
             case (true, true) {
	                  let t0 = rec(nl.left, nr.left);
	                  let t1 = rec(nl.right, nr.right);
	                  makeBin<K,V>(t0, t1)
	                };
             case (false, true) {
	                  assert(false);
	                  // XXX impossible, until we lift uniform depth assumption
	                  tr
	                };
             case (true, false) {
	                  assert(false);
	                  // XXX impossible, until we lift uniform depth assumption
	                  tr
	                };
             case (false, false) {
	                  /// handle hash collisions by using the association list:
	                  makeLeaf<K,V>(
                      AssocList.disj<Key<K>,V,V,V>(
                        nl.keyvals, nr.keyvals,
                        key_eq,
                        func (x:?V, y:?V):V = {
                          switch (x, y) {
                          case (null, null) {/* IMPOSSIBLE case: diverge. */ func x():V=x(); x()};
                          case (null, ?v) v;
                          case (?v, _) v;
                          }}
                      ))
	                };
	           }
           };
      }
    };
    rec(tl, tr)
  };

  // The key-value pairs of the final trie consists of those pairs of
  // the left trie whose keys are not present in the right trie; the
  // values of the right trie are irrelevant.
  func diff<K,V,W>(tl:Trie<K,V>, tr:Trie<K,W>, k_eq:(K,K)->Bool) : Trie<K,V> {
    let key_eq = keyEq<K>(k_eq);
    func rec(tl:Trie<K,V>, tr:Trie<K,W>) : Trie<K,V> {
      switch (tl, tr) {
      case (null, _) { return makeEmpty<K,V>() };
      case (_, null) { return tl };
      case (?nl,?nr) {
             switch (isBin<K,V>(tl),
	                   isBin<K,W>(tr)) {
             case (true, true) {
	                  let t0 = rec(nl.left, nr.left);
	                  let t1 = rec(nl.right, nr.right);
	                  makeBin<K,V>(t0, t1)
	                };
             case (false, true) {
	                  assert(false);
	                  // XXX impossible, until we lift uniform depth assumption
	                  tl
	                };
             case (true, false) {
	                  assert(false);
	                  // XXX impossible, until we lift uniform depth assumption
	                  tl
	                };
             case (false, false) {
                    assert(isLeaf<K,V>(tl));
	                  assert(isLeaf<K,W>(tr));
                    makeLeaf<K,V>(
                      AssocList.diff<Key<K>,V,W>(nl.keyvals, nr.keyvals, key_eq)
                    )
	                };
	           }
           };
      }};
    rec(tl, tr)
  };

  // This operation generalizes the notion of "set union" to finite maps.
  // Produces a "disjunctive image" of the two tries, where the values of
  // matching keys are combined with the given binary operator.
  //
  // For unmatched key-value pairs, the operator is still applied to
  // create the value in the image.  To accomodate these various
  // situations, the operator accepts optional values, but is never
  // applied to (null, null).
  //
  func disj<K,V,W,X>(tl:Trie<K,V>, tr:Trie<K,W>,
			               k_eq:(K,K)->Bool, vbin:(?V,?W)->X)
    : Trie<K,X>
  {
    let key_eq = keyEq<K>(k_eq);
    func recL(t:Trie<K,V>) : Trie<K,X> {
      switch t {
	    case (null) null;
	    case (? n) {
	           switch (matchLeaf<K,V>(t)) {
	           case (?_) { makeLeaf<K,X>(AssocList.disj<Key<K>,V,W,X>(n.keyvals, null, key_eq, vbin)) };
	           case _ { makeBin<K,X>(recL(n.left), recL(n.right)) }
	           }
           };
      }};
    func recR(t:Trie<K,W>) : Trie<K,X> {
      switch t {
	    case (null) null;
	    case (? n) {
	           switch (matchLeaf<K,W>(t)) {
	           case (?_) { makeLeaf<K,X>(AssocList.disj<Key<K>,V,W,X>(null, n.keyvals, key_eq, vbin)) };
	           case _ { makeBin<K,X>(recR(n.left), recR(n.right)) }
	           }
           };
      }};
    func rec(tl:Trie<K,V>, tr:Trie<K,W>) : Trie<K,X> {
      switch (tl, tr) {
        // empty-empty terminates early, all other cases do not.
      case (null, null) { makeEmpty<K,X>() };
      case (null, _   ) { recR(tr) };
      case (_,    null) { recL(tl) };
      case (? nl, ? nr) {
             switch (isBin<K,V>(tl),
	                   isBin<K,W>(tr)) {
             case (true, true) {
	                  let t0 = rec(nl.left, nr.left);
	                  let t1 = rec(nl.right, nr.right);
	                  makeBin<K,X>(t0, t1)
	                };
             case (false, true) {
	                  assert(false);
	                  // XXX impossible, until we lift uniform depth assumption
	                  makeEmpty<K,X>()
	                };
             case (true, false) {
	                  assert(false);
	                  // XXX impossible, until we lift uniform depth assumption
	                  makeEmpty<K,X>()
	                };
             case (false, false) {
	                  assert(isLeaf<K,V>(tl));
	                  assert(isLeaf<K,W>(tr));
                    makeLeaf<K,X>(
                      AssocList.disj<Key<K>,V,W,X>(nl.keyvals, nr.keyvals, key_eq, vbin)
                    )
                  };
	           }
           };
      }};
    rec(tl, tr)
  };

  // This operation generalizes the notion of "set intersection" to
  // finite maps.  Produces a "conjuctive image" of the two tries, where
  // the values of matching keys are combined with the given binary
  // operator, and unmatched key-value pairs are not present in the output.
  func conj<K,V,W,X>(tl:Trie<K,V>, tr:Trie<K,W>,
		                 k_eq:(K,K)->Bool, vbin:(V,W)->X)
    : Trie<K,X>
  {
    let key_eq = keyEq<K>(k_eq);
    func rec(tl:Trie<K,V>, tr:Trie<K,W>) : Trie<K,X> {
      switch (tl, tr) {
	    case (null, null) { return makeEmpty<K,X>() };
	    case (null, ? nr) { return makeEmpty<K,X>() };
	    case (? nl, null) { return makeEmpty<K,X>() };
	    case (? nl, ? nr) {
	           switch (isBin<K,V>(tl),
		                 isBin<K,W>(tr)) {
	           case (true, true) {
	                  let t0 = rec(nl.left, nr.left);
	                  let t1 = rec(nl.right, nr.right);
	                  makeBin<K,X>(t0, t1)
	                };
	           case (false, true) {
	                  assert(false);
	                  // XXX impossible, until we lift uniform depth assumption
	                  makeEmpty<K,X>()
	                };
	           case (true, false) {
	                  assert(false);
	                  // XXX impossible, until we lift uniform depth assumption
	                  makeEmpty<K,X>()
	                };
	           case (false, false) {
	                  assert(isLeaf<K,V>(tl));
	                  assert(isLeaf<K,W>(tr));
                    makeLeaf<K,X>(
                      AssocList.conj<Key<K>,V,W,X>(nl.keyvals, nr.keyvals, key_eq, vbin)
                    )
	                };
	           }
	         }
      }};
    rec(tl, tr)
  };

  // This operation gives a recursor for the internal structure of
  // tries.  Many common operations are instantiations of this function,
  // either as clients, or as hand-specialized versions (e.g., see map,
  // mapFilter, exists and forAll below).
  func foldUp<K,V,X>(t:Trie<K,V>, bin:(X,X)->X, leaf:(K,V)->X, empty:X) : X {
    func rec(t:Trie<K,V>) : X {
      switch t {
      case (null) { empty };
      case (?n) {
	           switch (matchLeaf<K,V>(t)) {
	           case (?kvs) {
                    AssocList.fold<Key<K>,V,X>(
                      kvs, empty,
                      func (k:Key<K>, v:V, x:X):X =
                        bin(leaf(k.key,v),x)
                    )
                  };
	           case null { bin(rec(n.left), rec(n.right)) };
	           }
           };
      }};
    rec(t)
  };

  // Fold over the key-value pairs of the trie, using an accumulator.
  // The key-value pairs have no reliable or meaningful ordering.
  func fold<K,V,X>(t:Trie<K,V>, f:(K,V,X)->X, x:X) : X {
    func rec(t:Trie<K,V>, x:X) : X {
      switch t {
      case (null) x;
      case (?n) {
	           switch (matchLeaf<K,V>(t)) {
	           case (?kvs) {
                    AssocList.fold<Key<K>,V,X>(
                      kvs, x,
                      func (k:Key<K>, v:V, x:X):X = f(k.key,v,x)
                    )
                  };
	           case null { rec(n.left,rec(n.right,x)) };
	           }
           };
      }};
    rec(t, x)
  };

  // specialized foldUp operation.
  func exists<K,V>(t:Trie<K,V>, f:(K,V)->Bool) : Bool {
    func rec(t:Trie<K,V>) : Bool {
      switch t {
      case (null) { false };
      case (?n) {
	           switch (matchLeaf<K,V>(t)) {
	           case (?kvs) {
                    List.exists<(Key<K>,V)>(
                      kvs, func ((k:Key<K>,v:V)):Bool=f(k.key,v)
                    )
                  };
	           case null { rec(n.left) or rec(n.right) };
	           }
           };
      }};
    rec(t)
  };


  // specialized foldUp operation.
  func forAll<K,V>(t:Trie<K,V>, f:(K,V)->Bool) : Bool {
    func rec(t:Trie<K,V>) : Bool {
      switch t {
      case (null) { true };
      case (?n) {
	           switch (matchLeaf<K,V>(t)) {
	           case (?kvs) {
                    List.all<(Key<K>,V)>(
                      kvs, func ((k:Key<K>,v:V)):Bool=f(k.key,v)
                    )
                  };
	           case null { rec(n.left) and rec(n.right) };
	           }
           };
      }};
    rec(t)
  };

  // specialized foldUp operation.
  // Test for "deep emptiness": subtrees that have branching structure,
  // but no leaves.  These can result from naive filtering operations;
  // filter uses this function to avoid creating such subtrees.
  func isEmpty<K,V>(t:Trie<K,V>) : Bool {
    func rec(t:Trie<K,V>) : Bool {
      switch t {
      case (null) { true };
      case (?n) {
	           switch (matchLeaf<K,V>(t)) {
	           case (?kvs) { List.isNil<(Key<K>,V)>(kvs) };
	           case null { rec(n.left) and rec(n.right) };
	           }
	         };
      }
    };
    rec(t)
  };

  func filter<K,V>(t:Trie<K,V>, f:(K,V)->Bool) : Trie<K,V> {
    func rec(t:Trie<K,V>) : Trie<K,V> {
      switch t {
      case (null) { null };
      case (?n) {
	           switch (matchLeaf<K,V>(t)) {
	           case (?kvs) {
                    makeLeaf<K,V>(
                      List.filter<(Key<K>,V)>(kvs, func ((k:Key<K>,v:V)):Bool = f(k.key,v))
                    )
		              };
	           case null {
		                let l = rec(n.left);
		                let r = rec(n.right);
		                switch (isEmpty<K,V>(l),
			                      isEmpty<K,V>(r)) {
		                case (true,  true)  null;
		                case (false, true)  r;
		                case (true,  false) l;
		                case (false, false) makeBin<K,V>(l, r);
		                }
		              };
	           }
	         };
      }
    };
    rec(t)
  };

  func mapFilter<K,V,W>(t:Trie<K,V>, f:(K,V)->?W) : Trie<K,W> {
    func rec(t:Trie<K,V>) : Trie<K,W> {
      switch t {
      case (null) { null };
      case (?n) {
	           switch (matchLeaf<K,V>(t)) {
	           case (?kvs) {
                    makeLeaf<K,W>(
                      List.mapFilter<(Key<K>,V),(Key<K>,W)>
                    (kvs,
                     // retain key and hash, but update key's value using f:
                     func ((k:Key<K>,v:V)):?(Key<K>,W) = {
                       switch (f(k.key,v)) {
                         case (null) null;
                         case (?w) (?(new {key=k.key; hash=k.hash}, w));
                       }}
                    ))
                  };
	           case null {
		                let l = rec(n.left);
		                let r = rec(n.right);
		                switch (isEmpty<K,W>(l),
			                      isEmpty<K,W>(r)) {
		                case (true,  true)  null;
		                case (false, true)  r;
		                case (true,  false) l;
		                case (false, false) makeBin<K,W>(l, r);
		                }
		              };
	           }
	         };
      }
    };
    rec(t)
  };

  // Test for equality, but naively, based on structure.
  // Does not attempt to remove "junk" in the tree;
  // For instance, a "smarter" approach would equate
  //   `#bin{left=#empty;right=#empty}`
  // with
  //   `#empty`.
  // We do not observe that equality here.
  func equalStructure<K,V>(
    tl:Trie<K,V>,
    tr:Trie<K,V>,
    keq:(K,K)->Bool,
    veq:(V,V)->Bool
  ) : Bool {
    func rec(tl:Trie<K,V>, tr:Trie<K,V>) : Bool {
      switch (tl, tr) {
      case (null, null) { true };
      case (_,    null) { false };
      case (null, _)    { false };
      case (?nl, ?nr) {
	           switch (matchLeaf<K,V>(tl),
		                 matchLeaf<K,V>(tr)) {
	           case (null,  null)  {
                    rec(nl.left, nr.left)
					          and rec(nl.right, nr.right)
                  };
	           case (null,  _) { false };
	           case (_, null)  { false };
	           case (?kvs1, ?kvs2) {
                    List.isEq<(Key<K>,V)>
                    (kvs1, kvs2,
                     func ((k1:Key<K>, v1:V), (k2:Key<K>, v2:V)) : Bool =
                       keq(k1.key, k2.key) and veq(v1,v2)
                    )
                  };
	           }
           };
      }};
    rec(tl, tr)
  };

};
