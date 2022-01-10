
function testmodel(m::ROSE.AbstractModel, atol=1e-4)
    img = intensitymap(m, 2*ROSE.radialextent(m), 2*ROSE.radialextent(m), 2048, 2048)
    @test isapprox(flux(m), flux(img), atol=atol)

    cache = ROSE.create_cache(ROSE.FFT(), m, img)
    u = fftshift(fftfreq(size(img,1), 1/img.psizex))
    @test isapprox(mean(collect(visibilities(m, u, u))), mean(cache.sitp.(u, u)), atol=atol)
end

@testset "Primitive models" begin

    @testset "Gaussian" begin
        m = Gaussian()
        testmodel(m, 1e-5)
    end

    @testset "Disk" begin
        m = Disk()
        testmodel(m)
    end


    @testset "MRing1" begin
        α = (0.25,)
        β = (0.1,)

        # We convolve it to remove some pixel effects
        m = convolved(MRing(α, β), stretched(Gaussian(), 0.1, 0.1))
        testmodel(m)
    end

    @testset "MRing2" begin
        α = (0.25, -0.1)
        β = (0.1, 0.2)

        # We convolve it to remove some pixel effects
        m = convolved(MRing(α, β), stretched(Gaussian(), 0.1, 0.1))
        testmodel(m)
    end


    @testset "ConcordanceCrescent" begin
        m = ConcordanceCrescent(20.0, 10.0, 5.0, 0.5)
        testmodel(m)
    end


    @testset "Crescent" begin
        m = convolved(Crescent(5.0, 2.0, 1.0, 0.5), stretched(Gaussian(), 0.1, 0.1))
        testmodel(m, 1e-3)
    end

    @testset "ExtendedRing" begin
        m = modelimage(ExtendedRing(10.0, 0.5), IntensityMap(zeros(2048,2048), 50.0, 50.0))
        testmodel(m)
    end
end



@testset "Modifiers" begin
    ma = Gaussian()
    mb = ExtendedRing(2.0, 10.0)
    @testset "Shifted" begin
        mas = shifted(ma, 0.5, 0.5)
        mbs = shifted(mb, 0.5, 0.5)
        testmodel(mas)
        testmodel(modelimage(mbs, IntensityMap(zeros(2048, 2048),
                                               2*ROSE.radialextent(mbs),
                                               2*ROSE.radialextent(mbs))))
    end

    @testset "Renormed" begin
        m1 = 3.0*ma
        m2 = ma*3.0
        @test visibility(m1, 4.0, 0.0) == visibility(m2, 4.0, 0.0)
        mbs = 3.0*mb
        testmodel(m1)
        testmodel(modelimage(mbs, IntensityMap(zeros(2048, 2048),
                                               2*ROSE.radialextent(mbs),
                                               2*ROSE.radialextent(mbs))))
    end

    @testset "Stretched" begin
        mas = stretched(ma, 5.0, 4.0)
        mbs = stretched(mb, 5.0, 4.0)
        testmodel(mas)
        testmodel(modelimage(mbs, IntensityMap(zeros(2048, 2048),
                                               2*ROSE.radialextent(mbs),
                                               2*ROSE.radialextent(mbs))))
    end

    @testset "Rotated" begin
        mas = rotated(ma, π/3)
        mbs = rotated(mb, π/3)
        testmodel(mas)
        testmodel(modelimage(mbs, IntensityMap(zeros(2048, 2048),
                                               2*ROSE.radialextent(mbs),
                                               2*ROSE.radialextent(mbs))))
    end

    @testset "AllMods" begin
        mas = rotated(stretched(shifted(ma, 0.5, 0.5), 5.0, 4.0), π/3)
        mbs = rotated(stretched(shifted(mb, 0.5, 0.5), 5.0, 4.0), π/3)
        testmodel(mas)
        testmodel(modelimage(mbs, IntensityMap(zeros(2048, 2048),
                                               2*ROSE.radialextent(mbs),
                                               2*ROSE.radialextent(mbs))))
    end
end

@testset "CompositeModels" begin
    m1 = Gaussian()
    m2 = ExtendedRing(2.0, 10.0)

    @testset "Add models" begin
        img = IntensityMap(zeros(2048, 2048),
                     15.0,
                     15.0)
        mt1 = m1 + m2
        mt2 = shifted(m1, 1.0, 1.0) + m2
        mt3 = shifted(m1, 1.0, 1.0) + 0.5*stretched(m2, 0.9, 0.8)
        mc = ROSE.components(mt1)
        @test mc[1] === m1
        @test mc[2] === m2

        testmodel(modelimage(mt1, img))
        testmodel(modelimage(mt2, img))
        testmodel(modelimage(mt3, img))
    end

    @testset "Convolved models" begin
        img = IntensityMap(zeros(2048, 2048),
                     15.0,
                     15.0)
        mt1 = convolved(m1, m2)
        mt2 = convolved(shifted(m1, 1.0, 1.0), m2)
        mt3 = convolved(shifted(m1, 1.0, 1.0), 0.5*stretched(m2, 0.9, 0.8))
        mc = ROSE.components(mt1)
        @test mc[1] === m1
        @test mc[2] === m2

        testmodel(modelimage(mt1, img))
        testmodel(modelimage(mt2, img))
        testmodel(modelimage(mt3, img))
    end

    @testset "All composite" begin
        img = IntensityMap(zeros(2048, 2048),
        15.0,
        15.0)

        mt = m1 + convolved(m1, m2)
        mc = ROSE.components(mt)
        @test mc[1] === m1
        @test mc[2] === m1
        @test mc[3] === m2

        testmodel(modelimage(mt, img))

    end
end

@testset "PolarizedModel" begin
    mI = stretched(MRing((0.2,), (0.1,)), 20.0, 20.0)
    mQ = 0.2*stretched(MRing((0.0,), (0.6,)), 20.0, 20.0)
    mU = 0.2*stretched(MRing((0.1,), (-0.6,)), 20.0, 20.0)
    mV = 0.0*stretched(MRing((0.0,), (-0.6,)), 20.0, 20.0)
    m = PolarizedModel(mI, mQ, mU, mV)

    v = coherencymatrix(m, 0.005, 0.01)
    @test evpa(v) == evpa(m, 0.005, 0.01)
    @test m̆(v) == m̆(m, 0.005, 0.01)

    I = IntensityMap(zeros(2048,2048), 100.0, 100.0)
    Q = similar(I)
    U = similar(I)
    V = similar(I)
    pimg1 = PolarizedMap(I,Q,U,V)
    intensitymap!(pimg1, m)
    pimg2 = intensitymap(m, 100.0, 100.0, 2048, 2048)
    @test pimg1.I == pimg2.I
    @test pimg1.Q == pimg2.Q
    @test pimg1.U == pimg2.U
    @test pimg1.V == pimg2.V

end