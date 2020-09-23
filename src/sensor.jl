# init sensor figure
function sensorinit(s::mjSim)
    # set figure to default
    mjv_defaultFigure(s.figsensor)

    # set flags
    s.figsensor[].flg_extend = Cint(1)
    s.figsensor[].flg_barplot = Cint(1)

    s.figsensor[].title = str2vec("Sensor data", length(s.figsensor[].title))

    # y-tick nubmer format
    s.figsensor[].yformat = str2vec("%.0f", length(s.figsensor[].yformat))

    # grid size
    s.figsensor[].gridsize = [2, 3]

    # minimum range
    s.figsensor[].range = [[0 1],[-1 1]]
end

# update sensor figure
function sensorupdate(s::mjSim)
    m = s.m
    d = s.d

    # loop over sensors
    for n=1:m.nsensor
        # get info about this sensor
        cutoff = m.sensor_cutoff[n] > 0 ? m.sensor_cutoff[n] : 1.0
        adr = m.sensor_adr[n]
        dim = m.sensor_dim[n]

        # Print out the sensor name and current values
        print("$(mj_id2name(m, mj.OBJ_SENSOR, n-1)): ")
        for i=0:(dim-1)
            i > 0 && print(", ")
            print(round(d.sensordata[adr+i+1], digits = 3))
        end
        println()
    end
end

# show sensor figure
function sensorshow(s::mjSim, rect::mjrRect)
    # render figure on the right
    viewport = mjrRect(rect.width - rect.width / 4,
                       rect.bottom,
                       rect.width / 4,
                       rect.height / 3)
    mjr_figure(viewport, s.figsensor, s.con)
end
