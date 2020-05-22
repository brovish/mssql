# this would run inside the image and that is not what we want. We want to create a volume outside the image
# Step1.cmd creates a volume on the host
# docker volume create sql_volume