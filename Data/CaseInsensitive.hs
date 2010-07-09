{-# LANGUAGE NoImplicitPrelude
           , UnicodeSyntax
           , TypeSynonymInstances
           , DeriveDataTypeable
  #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  Data.CaseInsensitive
-- Copyright   :  (c) 2010 Bas van Dijk
-- License     :  BSD-style (see the file LICENSE)
-- Maintainer  :  Bas van Dijk <v.dijk.bas@gmail.com>
--
-----------------------------------------------------------------------------

module Data.CaseInsensitive ( CI
                            , ci
                            , original
                            , mapCI
                            , ToLower(toLower)
                            ) where

--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

-- from base:
import Data.Eq       ( Eq((==)) )
import Data.Ord      ( Ord((<=)) )
import Data.Function ( on )
import Data.Functor  ( fmap )
import Data.List     ( map )
import Data.Monoid   ( Monoid(mempty, mappend) )
import Data.String   ( IsString(fromString) )
import Data.Typeable ( Typeable )
import Data.Word     ( Word8 )
import Data.Char     ( Char )
import qualified Data.Char as Char ( toLower )
import Text.Read     ( Read(readPrec) )
import Text.Show     ( Show(showsPrec), ShowS )

-- from base-unicode-symbols:
import Data.Function.Unicode ( (∘) )

-- from bytestring:
import Data.ByteString.Internal ( c2w, w2c )

import qualified Data.ByteString      as B  ( ByteString, map )
import qualified Data.ByteString.Lazy as BL ( ByteString, map )


--------------------------------------------------------------------------------
-- Case Insensitive Strings
--------------------------------------------------------------------------------

{-| A @CI s@ provides /C/ase /I/nsensitive comparison for the string-like @s@.

Note that @CI s@ has an instance for 'IsString' which together with the
@OverloadedStrings@ LANGUAGE extension allows you to write case insensitive
string literals as in:

@
\> (\"Get\" :: 'CI' String) == (\"GET\" :: 'CI' String)
True
@

-}
data CI s = CI { original   ∷ s -- ^ Retrieve the original string-like value.
               , lowerCased ∷ s
               }
          deriving Typeable

-- | Wrap a string-like value into the case insenstive wrapper so that it can be
-- compared case insensitively.
ci ∷ ToLower s ⇒ s → CI s
ci s = CI s (toLower s)

-- | Transform the wrapped string-like value.
mapCI ∷ ToLower s2 ⇒ (s1 → s2) → (CI s1 → CI s2)
mapCI f = ci ∘ f ∘ original

instance (IsString s, ToLower s) ⇒ IsString (CI s) where
    fromString = ci ∘ fromString

instance Monoid s ⇒ Monoid (CI s) where
    mempty = CI mempty mempty
    CI o1 l1 `mappend` CI o2 l2 = CI (o1 `mappend` o2) (l1 `mappend` l2)

instance Eq s ⇒ Eq (CI s) where
    (==) = (==) `on` lowerCased

instance Ord s ⇒ Ord (CI s) where
    (<=) = (<=) `on` lowerCased

instance (Read s, ToLower s) ⇒ Read (CI s) where
    readPrec = fmap ci readPrec

instance Show s ⇒ Show (CI s) where
    showsPrec prec = showsPrec prec ∘ original


--------------------------------------------------------------------------------
-- Lowering case
--------------------------------------------------------------------------------

-- | Class of string-like types that support lowering cases.
class ToLower s where toLower ∷ s → s

instance ToLower Char            where toLower = Char.toLower
instance ToLower Word8           where toLower = c2w ∘ toLower ∘ w2c
instance ToLower s ⇒ ToLower [s] where toLower = map toLower
instance ToLower B.ByteString    where toLower = B.map toLower
instance ToLower BL.ByteString   where toLower = BL.map toLower
instance ToLower ShowS           where toLower = (toLower ∘)
instance ToLower (CI s)          where toLower (CI _ l) = CI l l


-- The End ---------------------------------------------------------------------