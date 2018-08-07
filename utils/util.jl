include("network.jl")

using JuMP
using MathProgBase
using GLPKMathProgInterface

function init_layer(model, i, layerSizes, f)
	 bias = Vector{Float64}(layerSizes[i+1])
     weights = Matrix{Float64}(layerSizes[i + 1], layerSizes[i])

	 # first read in weights
	 for r = 1: layerSizes[i+1]
	 	line = readline(f)
		record = split(line, ",")
		token = record[1]
		c = 1
		for c = 1: layerSizes[i]
			weights[r, c] = parse(Float64, token)
			token = record[c]
		end
	 end

	 # now read in bias
	 for r = 1: layerSizes[i+1]
	 	line = readline(f)
		record = split(line, ",")
		bias[r] = parse(Float64, record[1])
	 end

	 # initialize variables for neurons and deltas
     return Layer(weights, bias)
end
	
function read_nnet(fname)
    f = open(fname)
	
	line = readline(f)
    while contains(line, "//") #skip comments
    	line = readline(f)
    end

	record = split(line, ",")
    nLayers = parse(Int64, record[1])
    record = split(readline(f), ",")
    layerSizes = Vector{Int64}(nLayers + 1)
    for i = 1: nLayers + 1
    	layerSizes[i] = parse(Int64, record[i])
    end

	# read past additonal information to get weight/bias values
    for i = 1: 5
    	line = readline(f)
    end	

	# initialize layers
	model = Model(solver=GLPKSolverMIP())
    layers = Vector{Layer}(nLayers)
	for i = 1:nLayers
        curr_layer = init_layer(model, i, layerSizes, f)
		layers[i] = curr_layer
	end

	return Network(layers)

end