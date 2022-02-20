using .NestedSamplers


samplertype(::Type{<:Nested}) = IsNested()

function AbstractMCMC.sample(post::TransformedPosterior, sampler::Nested, args...; kwargs...)
    ℓ(x) = logdensity(post, x)
    model = NestedModel(ℓ, identity)

    samples, stats = sample(model, sampler, args...; chain_type=Array, kwargs...)
    weights = samples[:, end]
    chain = transform.(Ref(post), eachrow(samples[:,1:end-1]))
    return TupleVector(chain), merge((;weights,), stats)
end