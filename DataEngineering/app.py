import datetime as dt
import numpy as np
import pandas as pd

import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, func

from flask import Flask, jsonify

# create engine, automap, and reflect db
engine = create_engine("sqlite:///hawaii.sqlite")
Base = automap_base()
Base.prepare(engine, reflect=True)

# reference to measure and station tables.
Measure = Base.classes.measure_sql
Station = Base.classes.station_sql

# Create our session (link) from Python to the DB
session = Session(engine)

#################################################
# Flask Setup
#################################################
app = Flask(__name__)

@app.route("/")
def welcome():
    """List all available api routes."""
    return (
        f"Available Routes:<br/>"
        f"/api/v1.0/precipitation<br/>"
        f"/api/v1.0/stations<br/>"
        f"/api/v1.0/tobs<br/>"
        f"/api/v1.0/tobs/&lt;start&gt;<br/>"
        f"/api/v1.0/tobs/&lt;start&gt;/&lt;end&gt;<br/>"
    )


@app.route("/api/v1.0/precipitation")
def prcp():
    """Dates and temperatures from last year"""
    # Query all measurements
    results = session.query(Measure.date, Measure.prcp).\
    filter(Measure.date <= '2017-05-01').\
    filter(Measure.date >= '2016-05-01').all()

    prcp_list = []
    for item in results:
        prcp_dict = {}
        prcp_dict["date"] = Measure.date
        prcp_dict["prcp"] = Measure.prcp
        prcp_list.append(prcp_dict)

    return jsonify(results)

@app.route("/api/v1.0/stations")
def stations():
    """List of Stations"""
    # Query all stations
    total_stations = session.query(Station.station).all()

    stations_list = list(np.ravel(total_stations))

    return jsonify(stations_list)

@app.route("/api/v1.0/tobs")
def tobs():
    """Temps Past Year"""
    # Query all stations
    results = session.query(func.min(Measure.tobs), func.max(Measure.tobs), func.avg(Measure.tobs)).\
        filter(Measure.date <= '2017-05-01').\
        filter(Measure.date >= '2016-05-01').all()[0]

    tobs_list = list(np.ravel(results))
    
    return jsonify(tobs_list)


@app.route("/api/v1.0/tobs/<start>")
def start_only(start='2016-05-01'):
    """Get tmax, tmin, and taverage for start date to end of data."""
    sel = [
        func.min(Measure.tobs), 
        func.max(Measure.tobs), 
        func.avg(Measure.tobs)]

    results = session.query(*sel).\
        filter(Measure.date >= start).all()[0]

    sum_list = list(np.ravel(results))

    return jsonify(sum_list)

@app.route("/api/v1.0/tobs/<start>/<end>")
def start_end(start='2016-05-01', end='2017-01-01'):
    """Get tmax, tmin, and taverage for start and end date entered."""
    sel = [
        func.min(Measure.tobs), 
        func.max(Measure.tobs), 
        func.avg(Measure.tobs)]

    results = session.query(*sel).\
        filter(Measure.date <= end).\
        filter(Measure.date >= start).all()[0]

    sum_list = list(np.ravel(results))

    return jsonify(sum_list)



if __name__ == '__main__':
    app.run(debug=True)
