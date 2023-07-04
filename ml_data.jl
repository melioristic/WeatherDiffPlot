using GLMakie
using NCDatasets
using GeometryBasics

function change_base_cord(data)
    new_data = zeros(Float32, size(data)[1], size(data)[2], size(data)[3] )
    new_data[1:Int8(size(data)[1]/2)+1, :, :] = reverse(data[1:Int8(size(data)[1]/2)+1, :, :], dims=1)
    new_data[Int8(size(data)[1]/2):end, :, :] = reverse(data[Int8(size(data)[1]/2):end, :, :], dims=1)
    return new_data ;
end

NCDataset("/Users/anand/Documents/data/WeatherDiff/geopotential_1979_5.625deg.nc")["level"][:]

function read_data()
    t2m_data = NCDataset("/Users/anand/Documents/data/WeatherDiff/2m_temperature_2018_5.625deg.nc")["t2m"] 
    gp_data = NCDataset("/Users/anand/Documents/data/WeatherDiff/geopotential_1979_5.625deg.nc")["z"]
    tp_data = NCDataset("/Users/anand/Documents/data/WeatherDiff/total_precipitation_1979_5.625deg.nc")["tp"]
    oro = NCDataset("/Users/anand/Documents/data/WeatherDiff/constants_5.625deg.nc")["orography"]

    oro_new = zeros(Float32, size(oro)[1], size(oro)[2])
    oro_new[1:Int8(size(oro)[1]/2)+1, :] = oro[Int8(size(oro)[1]/2):end, :]    
    oro_new[Int8(size(oro)[1]/2):end, :] = oro[1:Int8(size(oro)[1]/2)+1, :]    
    
    # oro = change_base_cord(oro)
    gp_new = zeros(Float32, size(gp_data)[1],size(gp_data)[2], 5, 500 )

    gp_new[:,:,1,:] = change_base_cord(gp_data[:,:,1,1:500])
    gp_new[:,:,2,:] = change_base_cord(gp_data[:,:,5,1:500])
    gp_new[:,:,3,:] = change_base_cord(gp_data[:,:,8,1:500])
    gp_new[:,:,4,:] = change_base_cord(gp_data[:,:,9,1:500])
    gp_new[:,:,5,:] = change_base_cord(gp_data[:,:,10,1:500])
    
    t2m_data = change_base_cord(t2m_data[:,:,1:500])
    tp_data = change_base_cord(tp_data[:,:,1:500])

    
    return t2m_data, gp_new, tp_data, oro_new
end


t2m_data, gp_data, tp_data,  oro= read_data()

f = Figure(resolution = (500,600))
ax = Axis3(f[1,1], limits=((0, 100), (0, 150), (0, 300)), azimuth=0.15*pi, aspect=(1,1,2) )
f

# Plot gp at t
for i=1:5
    hm = heatmap!(gp_data[:,:,i, i], transformation=(:xz,0))
    translate!(hm , 0, 0, 50*(i-1))
end
f


# Plot gp at t-1

for i=1:5
    hm = heatmap!(gp_data[:,:,i, i+5], transformation=(:xz,0))
    translate!(hm, 0, 64, 50*(i-1))
end
f


hm = heatmap!(log.(oro[:,:,1].+200), transformation=(:yz,0), colormap=:terrain)
translate!(hm, 0, 0,250)
f

hm = heatmap!(gp_data[:,:,3,21], transformation=(:xz,0))
translate!(hm, 0, 64*3, 175)
f

# plot oro




hidespines!(ax)
f
hidedecorations!(ax)
f
save("ml_data.png", f)