# things CUDA.jl can shuffle
shuffle_expr(var_name,::Type{UInt8}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))
shuffle_expr(var_name,::Type{UInt16}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))
shuffle_expr(var_name,::Type{UInt32}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))
shuffle_expr(var_name,::Type{UInt64}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))
shuffle_expr(var_name,::Type{UInt128}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))
shuffle_expr(var_name,::Type{Int8}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))
shuffle_expr(var_name,::Type{Int16}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))
shuffle_expr(var_name,::Type{Int32}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))
shuffle_expr(var_name,::Type{Int64}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))
shuffle_expr(var_name,::Type{Int128}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))
shuffle_expr(var_name,::Type{Float16}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))
shuffle_expr(var_name,::Type{Float32}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))
shuffle_expr(var_name,::Type{Float64}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))
shuffle_expr(var_name,::Type{Bool}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))
shuffle_expr(var_name,::Type{Complex}) = :($var_name = CUDA.shfl_sync(0xFFFFFFFF, $var_name, laneid() % 32 + 1))


# tuple
function shuffle_expr(var_name, tuple_type::Type{<:Tuple})
    # this is the sequence of lines that will form the body of the block
    shuffle_exprs = []
    # temp values from shuffling stored in these variable names which go into final constructor call
    local_var_names = []

    for (n, field_type) in enumerate(tuple_type.parameters)
        field_var_name = Symbol("field_$n")
        push!(local_var_names, field_var_name)
        push!(shuffle_exprs, :($field_var_name = $var_name[$n]))
        push!(shuffle_exprs, shuffle_expr(field_var_name, field_type))
    end

    quote
        $var_name = let
            $(Expr(:block, shuffle_exprs...))
            tuple($(local_var_names...))
        end
    end
end

# StaticArray 
function shuffle_expr(var_name, arr_type::Type{<:AbstractArray})
    # this is the sequence of lines that will form the body of the block
    shuffle_exprs = []
    # temp values from shuffling stored in these variable names which go into final constructor call
    local_var_names = []

    for (n, _) in enumerate(arr_type.parameters)
        field_var_name = Symbol("field_$n")
        push!(local_var_names, field_var_name)
        push!(shuffle_exprs, :($field_var_name = $var_name[$n]))
        push!(shuffle_exprs, shuffle_expr(field_var_name, field_type))
    end

    quote
        $var_name = let
            $(Expr(:block, shuffle_exprs...))
            tuple($(local_var_names...))
        end
    end
end