# ---
# title: Template Matching
# cover: assets/median.gif
# author: Michael Pusterhofer
# date: 2021-06-22
# ---

# This demo shows how to find objects in an image using template matching. 

# The main idea is to check the similarity between a search target(template) and a subsection of the image.
# The subsection is usually the same size as the template and every subsection must be assigned a value.
# This can be done using the [`mapwindow`](@ref) function

# At first we import the following packages. 
using Images
using Plots 

# Images enables the generation of Images, ImageFiltering provides the mapwindow function and ImageFeatures 
# provides functions to label segments of an image.

# To test the algorithm we first generate an image. For our case we will repeat a square image section which 
# will also work as our template.

template = zeros(5,5)
template[1] = 1
template[2,1] = template[1,2]= 2
template

img = repeat(template,outer=(4,4))
img

# Now that we have an image and a template we have to think have we measure the similarity between a
# section of the image and the template. This can be done in multiple way, but a sum of square distances should work quite well.
# The ImageDistance package provides an already optimized version called sqeuclidean, which can be used to define a function for mapwindow.
# Lets call it SDIFF.

function SDIFF(template)
  (patch)->sqeuclidean(patch .- template)
end

# To actually generate our similarity map we use mapwindow in the following way

res = mapwindow(SDIFF(template), img, size(template), border=Fill(1))
res
	
# If the subsection is located at the border of the image the image has to be extended and in our case we will
# fill all values outside the image with 1. As all of the square differences will be summed up per subsection 
# the resulting sum can be bigger than 1. This will be a problem if we just convert it to an image to check  the values.
# To rescale the values to be between 0 and 1 we can use imadjustintensity.

imadjustintensity(res)

#  To find the best locations we have to look for small values on the similarity map. This can be done by comparing
# if the pixel are below a certain value. LÖets chose a value of 0.1.

threshold = res .< 0.1

# Now we see small blobs at the locations which match our template and we can label the connected regions by label_components.
# This will enumerate are connected regions and component_centroids can be used to get the centroid of each region. 
# component_centroids also return the centroid for the backgroud region, which is at the first position and we will ommit it.

#cluster into compenents and calculate centroid
centroids = component_centroids(label_components(th))[2:end]

# To now see it it worked ciorrectly we can overlay the centroids with the original image using the Plots package.
# As the images are stored 
plot(Gray.(img))
scatter!(reverse.(centroids))
