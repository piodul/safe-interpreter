module AST.Basic where


newtype Program = Program [Command]

data Command
    = CSkip
    | CAssign LValue RValue
    | CDeclare VarRef RValue

newtype LValue
    = LVVariable VarRef

data RValue
    = RVFromLV LValue
    | RVLiteral Literal
    | RVOp Op RValue RValue

newtype VarRef = VR VarName
newtype Literal
    = LInteger Integer

type VarName = String
type Op = Integer -> Integer -> Integer
