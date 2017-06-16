{-# LANGUAGE Rank2Types #-}
module Parser where

import Control.Lens
import Control.Lens.Prism
import Text.Parsec

import AST.Basic
import Lexer hiding (token, PMonad)


type PMonad = Parsec [Token] ()


parse :: [Token] -> Either ParseError Program
parse = runParser parseProgram () "<stdin>"

parseProgram :: PMonad Program
parseProgram = undefined

parseCommand :: PMonad Command
parseCommand = do
    c <- parseCSkip <|> parseCAssign <|> parseCDeclare
    expect _TDSemicolon
    return c

parseCSkip :: PMonad Command
parseCSkip = expect _TDSemicolon >> return CSkip

parseCAssign :: PMonad Command
parseCAssign = do
    lv <- parseLValue
    expect _TDEquals
    rv <- parseRValue
    return $ CAssign lv rv

parseCDeclare :: PMonad Command
parseCDeclare = do
    expect _TDVar
    vr <- parseVarRef
    expect _TDEquals
    rv <- parseRValue
    return $ CDeclare vr rv

parseLValue :: PMonad LValue
parseLValue =
    LVVariable <$> parseVarRef

parseRValue :: PMonad RValue
parseRValue =
    RVFromLV <$> parseLValue
    <|> RVLiteral <$> parseLiteral
    <|> RVAdd <$> parseRValue <*> parseRValue

parseLiteral :: PMonad Literal
parseLiteral = LInteger <$> expect _TDIntegerLiteral

parseVarRef :: PMonad VarRef
parseVarRef = VR <$> parseName

parseName :: PMonad String
parseName = expect _TDName

expect :: Prism' TokenData a -> PMonad a
expect p = token show tokenPos $ \t -> tokenData t ^? p