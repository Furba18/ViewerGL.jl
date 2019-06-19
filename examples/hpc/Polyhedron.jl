using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Triangle
using Revise
using ViewerGL
GL = ViewerGL
using LinearAlgebra

const M44 = convert(GL.Matrix4, Matrix{Float64}(I,4,4))




"""

# Example

```

```
"""
function GLPolyhedron(V::Lar.Points,
	EV::Lar.ChainOp,FE::Lar.ChainOp,CF::Lar.ChainOp)
	# TODO
end



"""

# Example

```

```
"""
function GLPolyhedron(V::Lar.Points, FV::Lar.Cells, T::GL.Matrix4=M44)
	# data preparation
	function mycat(a::Lar.Cells)
		out=[]
		for cell in a append!(out,cell) end
		return out
	end
	vindexes = sort(collect(Set(mycat(FV))))
	W = V[:,vindexes]
	vdict = Dict(zip(vindexes,1:length(vindexes)))
	triangles = [[vdict[u],vdict[v],vdict[w]] for (u,v,w) in FV]
	points = (M44 * [W; ones(1,size(W,2))])[1:3,:]
	points = convert(Lar.Points, points') # points by row

	# mesh building
        vertices,normals = GL.lar2mesh(points,triangles)
        ret=GL.GLMesh(GL.GL_TRIANGLES)
        ret.vertices = GL.GLVertexBuffer(vertices)
        ret.normals  = GL.GLVertexBuffer(normals)
        return ret
end


# data input
(V, FV, EV) = ([1.01181 0.215639 0.91979 0.123616 1.02252 0.226347 0.930498 0.134324 0.0458309 -0.301827 0.348275 0.0006172 0.579367 0.23171 0.881811 0.534154 -0.0521776 0.627953 -0.190635 0.489496 -0.0233884 0.656742 -0.161846 0.518285 0.27652 -0.0875132 0.52527 0.161237 0.509324 0.145291 0.758074 0.394041 0.27631 0.564484 0.0058279 0.294002 1.01221 1.30039 0.741732 1.02991; 0.160033 0.0680099 0.956278 0.864255 0.160649 0.0686266 0.956895 0.864872 -0.200245 0.102199 0.417839 0.720283 -0.35354 -0.0510965 0.264543 0.566987 0.682359 0.543901 0.0592036 -0.0792537 0.956374 0.817917 0.333219 0.194762 -0.102028 0.146722 0.324834 0.573584 -0.16916 0.0795901 0.257702 0.506452 0.452356 0.181874 1.15396 0.883481 0.816151 0.545669 1.51776 1.24728; 0.196256 0.206963 0.196872 0.20758 0.997729 1.00844 0.998346 1.00905 0.0677451 0.601282 -0.0855504 0.447986 0.502301 1.03584 0.349005 0.882542 0.159301 0.18809 0.433316 0.462105 0.797002 0.825792 1.07102 1.09981 0.1446 0.377404 0.0774682 0.310272 0.580364 0.813168 0.513232 0.746036 0.403805 1.13971 0.767599 1.5035 0.249344 0.985248 0.613139 1.34904], Array{Int64,1}[[1,2,3,4],[5,6,7,8],[1,2,5,6],[3,4,7,8],[1,3,5,7],[2,4,6,8],[9,10,11,12],[13,14,15,16],[9,10,13,14],[11,12,15,16],[9,11,13,15],[10,12,14,16],[17,18,19,20],[21,22,23,24],[17,18,21,22],[19,20,23,24],[17,19,21,23],[18,20,22,24],[25,26,27,28],[29,30,31,32],[25,26,29,30],[27,28,31,32],[25,27,29,31],[26,28,30,32],[33,34,35,36],[37,38,39,40],[33,34,37,38],[35,36,39,40],[33,35,37,39],[34,36,38,40]],Array{Int64,1}[[1,2],[3,4],[5,6],[7,8],[1,3],[2,4],[5,7],[6,8],[1,5],[2,6],[3,7],[4,8],[9,10],[11,12],[13,14],[15,16],[9,11],[10,12],[13,15],[14,16],[9,13],[10,14],[11,15],[12,16],[17,18],[19,20],[21,22],[23,24],[17,19],[18,20],[21,23],[22,24],[17,21],[18,22],[19,23],[20,24],[25,26],[27,28],[29,30],[31,32],[25,27],[26,28],[29,31],[30,32],[25,29],[26,30],[27,31],[28,32],[33,34],[35,36],[37,38],[39,40],[33,35],[34,36],[37,39],[38,40],[33,37],[34,38],[35,39],[36,40]])

cop_EV = Lar.coboundary_0(EV::Lar.Cells);
cop_EW = convert(Lar.ChainOp, cop_EV);
cop_FE = Lar.coboundary_1(V, FV::Lar.Cells, EV::Lar.Cells);
W = convert(Lar.Points, V');

V, copEV, copFE, copCF = Lar.Arrangement.spatial_arrangement(
	W::Lar.Points, cop_EW::Lar.ChainOp, cop_FE::Lar.ChainOp)

cc = [copEV, copFE, copCF]
LarModelString = Lar.lar2obj(V::Lar.Points, cc::Lar.ChainComplex)
f = open("test/out3d.obj", "w")
print(f, LarModelString); close(f)
V,EVs,FVs = Lar.obj2lar("test/out3d.obj")

GL.VIEW([
      GLPolyhedron(V, FVs[1])
      GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])
