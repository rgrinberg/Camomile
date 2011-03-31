(* $Id: uTF16.mli,v 1.6 2004/06/05 16:42:07 yori Exp $ *)
(* Copyright 2002, 2003 Yamagata Yoriyuki. distributed with LGPL *)

(** UTF-16 encoded string. the type is the bigarray of 16-bit integers.
   The characters must be 21-bits code points, and not surrogate points,
   0xfffe, 0xffff.
   Bigarray.cma or Bigarray.cmxa must be linked when this module is used. *)
type t = 
    (int, Bigarray.int16_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t

exception Malformed_code

(** [validate s]
   If [s] is valid UTF-16 then successes otherwise raises [Malformed_code].
   Other functions assume strings are valid UTF-16, so it is prudent
   to test their validity for strings from untrusted origins. *)
val validate : t -> unit

(** All functions below assume strings are valid UTF-16.  If not,
   the result is unspecified. *)

(** [get s n] returns [n]-th Unicode character of [s].
   The call requires O(n)-time. *)
val get : t -> int -> UChar.t

exception Out_of_range

(** [init len f]
   returns a new string which contains [len] Unicode characters.
   The i-th Unicode character is initialized by [f i] 
   if the character is not representable, raise [Out_of_range]. *)
val init : int -> (int -> UChar.t) -> t

(** [length s] returns the number of Unicode characters contained in s *)
val length : t -> int
    
(** Positions in the string represented by the number of 16-bit unit
   from the head.
   The location of the first character is [0] *)
type index = int

(** [nth s n] returns the position of the [n]-th Unicode character. 
   The call requires O(n)-time *)
val nth : t -> int -> index

(** [first s] : The position of the head of the last Unicode character. *)
val first : t -> index

(** [last s] : The position of the head of the last Unicode character. *)
val last : t -> index

(** [look s i ]
   returns the Unicode character of the location [i] in the string [s]. *)
val look : t -> index -> UChar.t

(** [out_of_range s i] tests whether [i] is inside of [s]. *)
val out_of_range : t -> index -> bool

(** [compare_aux s i1 i2] returns
 - If [i1] is the position located before [i2], a value < 0,
 - If [i1] and [i2] points the same location, 0,
 - If [i1] is the position located after [i2], a value > 0. 

*)
val compare_index : t -> index -> index -> int

(** [next s i]
   returns the position of the head of the Unicode character
   located immediately after [i]. 
 - If [i] is a valid position, the function always success.
 - If [i] is a valid position and there is no Unicode character after [i],
   the position outside [s] is returned.  
 - If [i] is not a valid position, the behaviour is undefined. 
 
*)
val next : t -> index -> index

(** [prev s i]
   returns the position of the head of the Unicode character
   located immediately before [i]. 
   - If [i] is a valid position, the function always success.
   - If [i] is a valid position and there is no Unicode character before [i],
   the position outside [s] is returned.  
   - If [i] is not a valid position, the behaviour is undefined. 

*)
val prev : t -> index -> index

(* [move s i n]
 - If n >= 0, returns [n]-th Unicode character after [i].
 - If n < 0, returns [-n]-th Unicode character before [i].
 0 If there is no such character, the result is unspecified.
 
*)
val move : t -> index -> int -> index
    
(** [iter f s]
   Apply [f] to all Unicode characters in [s].  
   The order of application is same to the order 
   in the Unicode characters in [s]. *)
val iter : (UChar.t -> unit) -> t -> unit

(** Code point comparison *)
val compare : t -> t -> int

(** Buffer module for UTF-16 *)
module Buf : sig
  type buf

  (** create n : creates the buffer with the initial size [n]. *)   
  val create : int -> buf

  (** The rest of functions is similar to the ones of Buffer in stdlib. *)

  val contents : buf -> t
  val clear : buf -> unit
  val reset : buf -> unit

  (** if the character is not representable, raise Out_of_range *)
  val add_char : buf -> UChar.t -> unit

  val add_string : buf -> t -> unit
  val add_buffer : buf -> buf -> unit
end