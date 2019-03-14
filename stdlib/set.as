/**
 
 Sets
 ========

 Sets are partial maps from element type to unit type,
 i.e., the partial map represents the set with its domain.

 TODO-Matthew:
 ---------------

 - for now, we pass a hash value each time we pass an element value;
   in the future, we might avoid passing element hashes with each element in the API;
   related to: https://dfinity.atlassian.net/browse/AST-32

 - similarly, we pass an equality function when we do some operations.
   in the future, we might avoid this via https://dfinity.atlassian.net/browse/AST-32

*/

type Set<T> = Trie<T,()>;

let Set = new {

  func empty<T>():Set<T> =
    Trie.empty<T,()>();

  func insert<T>(s:Set<T>, x:T, xh:Hash, eq:(T,T)->Bool) : Set<T> = {
    let (s2, _) = Trie.insert<T,()>(s, new {key=x; hash=xh}, eq, ());
    s2
  };

  func remove<T>(s:Set<T>, x:T, xh:Hash, eq:(T,T)->Bool) : Set<T> = {
    let (s2, _) = Trie.remove<T,()>(s, new {key=x; hash=xh}, eq);
    s2
  };

  func eq<T>(s1:Set<T>, s2:Set<T>, eq:(T,T)->Bool):Bool {
    // XXX: Todo: use a smarter check
    Trie.equalStructure<T,()>(s1, s2, eq, unitEq)
  };

  func card<T>(s:Set<T>) : Nat {
    Trie.foldUp<T,(),Nat>
    (s,
     func(n:Nat,m:Nat):Nat{n+m},
     func(_:T,_:()):Nat{1},
     0)
  };

  func mem<T>(s:Set<T>, x:T, xh:Hash, eq:(T,T)->Bool):Bool {
    switch (Trie.find<T,()>(s, new {key=x; hash=xh}, eq)) {
    case null { false };
    case (?_) { true };
    }
  };

  func union<T>(s1:Set<T>, s2:Set<T>, eq:(T,T)->Bool):Set<T> {
    let s3 = Trie.merge<T,()>(s1, s2, eq);
    s3
  };

  func diff<T>(s1:Set<T>, s2:Set<T>, eq:(T,T)->Bool):Set<T> {
    let s3 = Trie.diff<T,(),()>(s1, s2, eq);
    s3
  };

  func intersect<T>(s1:Set<T>, s2:Set<T>, eq:(T,T)->Bool):Set<T> {
    let noop : ((),())->(()) = func (_:(),_:()):(())=();
    let s3 = Trie.conj<T,(),(),()>(s1, s2, eq, noop);
    s3
  };

  func unitEq (_:(),_:()):Bool{ true };

};
