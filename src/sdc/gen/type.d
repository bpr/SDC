/**
 * Copyright 2010 Bernard Helyer
 * This file is part of SDC. SDC is licensed under the GPL.
 * See LICENCE or sdc.d for more details.
 */
module sdc.gen.type;

import std.string;

import llvm.c.Core;

import ast = sdc.ast.all;
import sdc.gen.sdcmodule;
import sdc.gen.value;


Type astTypeToBackendType(ast.Type, Module mod)
{
    return new Int32Type(mod);
}


interface Type
{
    LLVMTypeRef llvmType();
}


class IntegerType(alias LLVMTypeFunction) : Type
{
    this(Module mod)
    {
        mModule = mod;
        mType = LLVMTypeFunction(mod.context);
    }
    
    LLVMTypeRef llvmType()
    {
        return mType;
    }
    
    protected Module mModule;
    protected LLVMTypeRef mType;
}

// The instances of this class are in the value module.

class FunctionType : Type
{
    this(Module mod, ast.FunctionDeclaration funcDecl)
    {
        mModule = mod;
        mFunctionDeclaration = funcDecl;
    }
    
    void declare()
    {
        auto retval = astTypeToBackendType(mFunctionDeclaration.retval, mModule);
        LLVMTypeRef[] params;
        foreach (param; mFunctionDeclaration.parameters) {
            mParameters ~= astTypeToBackendType(param.type, mModule);
            params ~= mParameters[$ - 1].llvmType;
        }
        mType = LLVMFunctionType(retval.llvmType, params.ptr, params.length, false);
    }
    
    LLVMTypeRef llvmType()
    {
        return mType;
    }
        
    protected Module mModule;
    protected LLVMTypeRef mType;
    protected ast.FunctionDeclaration mFunctionDeclaration;
    protected Type[] mParameters;
}