using GLMakie
using NCDatasets
using GeometryBasics

function change_base_cord(data)
    new_data = zeros(Float32, size(data)[1], size(data)[2], size(data)[3] )
    new_data[1:Int8(size(data)[1]/2)+1, :, :] = reverse(data[1:Int8(size(data)[1]/2)+1, :, :], dims=1)
    new_data[Int8(size(data)[1]/2):end, :, :] = reverse(data[Int8(size(data)[1]/2):end, :, :], dims=1)
    return new_data ;
end

function read_data()
    t2m_data = NCDataset("/Users/anand/Documents/data/WeatherDiff/2m_temperature_2018_5.625deg.nc")["t2m"] 
    gp_data = NCDataset("/Users/anand/Documents/data/WeatherDiff/geopotential_500hPa_1979_5.625deg.nc")["z"]
    tp_data = NCDataset("/Users/anand/Documents/data/WeatherDiff/total_precipitation_1979_5.625deg.nc")["tp"]

    gp_data = change_base_cord(gp_data[:,:,1:500])
    t2m_data = change_base_cord(t2m_data[:,:,1:500])
    tp_data = change_base_cord(tp_data[:,:,1:500])
    return t2m_data, gp_data, tp_data
end

t2m_data, gp_data, tp_data = read_data()

f = Figure(resolution = (1400,700))
ax = Axis3(f[1,1], limits=((0, 64), (0, 550), (0, 32)), azimuth=0.25*pi, aspect=(1,6,1) )

xmin, ymin, zmin = minimum(ax.finallimits[])
xmax, ymax, zmax = maximum(ax.finallimits[])

fact = 5
for i=1:36*fact
    heatmap!(gp_data[:,:,i], transformation=(:xz,2*(i)))
end
# ends at 360
f

gap = 20

for i=1:1*fact
    heatmap!(gp_data[:,:,i], transformation=(:xz,2*(i+180+gap)))
end
#ends at 410
f

for i=1:2*fact
    heatmap!(gp_data[:,:,i], transformation=(:xz,2*(i+205+gap)))
end
f

hidespines!(ax)
hidedecorations!(ax)
f
save("tvt_split.png", f)