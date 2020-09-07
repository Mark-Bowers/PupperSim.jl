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
    #=
    println("sensorupdate")
    maxline = 10

    for i=1:maxline # clear linepnt
        mj.set(s.figsensor, :linepnt, Cint(0), i)
    end

    lineid = 1 # start with line 0
    m = s.m
    d = s.d

    # loop over sensors
    for n=1:m.m[].nsensor
        # go to next line if type is different
        if (n > 1 && m.sensor_type[n] != m.sensor_type[n - 1])
            lineid = min(lineid+1, maxline)
        end

        # get info about this sensor
        cutoff = m.sensor_cutoff[n] > 0 ? m.sensor_cutoff[n] : 1.0
        adr = m.sensor_adr[n]
        dim = m.sensor_dim[n]

        # data pointer in line
        p = mj.get(s.figsensor, :linepnt, lineid)

        # fill in data for this sensor
        for i=0:(dim-1)
            # check size
            if ((p + 2i) >= Int(mj.MAXLINEPNT) / 2) break end

            x1 = 2p + 4i + 1
            x2 = 2p + 4i + 3
            mj.set(s.figsensor, :linedata, adr+i, lineid, x1)
            mj.set(s.figsensor, :linedata, adr+i, lineid, x2)

            y1 = 2p + 4i + 2
            y2 = 2p + 4i + 4
            se = d.sensordata[adr+i+1]/cutoff
            mj.set(s.figsensor, :linedata,  0, lineid, y1)
            mj.set(s.figsensor, :linedata, se, lineid, y2)
        end

        # update linepnt
        mj.set(s.figsensor, :linepnt,
                min(Int(mj.MAXLINEPNT)-1, p+2dim),
                lineid)
    end
    =#
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
