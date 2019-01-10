// Various JS for EventingSubgame

window.EventingSubgame = {
    activate: function(model) {
        window.EventingSubgame.startHandler();
        window.EventingSubgame.activated++;
    },
    deactivate: function(model) {
        _.pull(window.EventingSubgame.models, model);
        window.EventingSubgame.activated--;
    },
    startHandler: function() {
        window.requestAnimationFrame(window.EventingSubgame.handler);
    },
    handler: function(timestamp) {
        if(window.EventingSubgame.activated < 1) return;

        window.EventingSubgame.models.forEach(function(m) {
            m.update(timestamp);
        });
    },
    // Receive a subgame event from the server
    receive: function(data) {
    },
    activated: 0,
    models: []
};

// This is the abstract superclass that handles simple construction
// and basic advancing of time, but with no actual logic. A subclass
// should override advanceTime in order to be usable.
class AbstractModel {
    constructor(initialTime) {
        this.time = initialTime;
    }

    get time() {
        return this.time;
    }

    update(timestamp) {
        timeDiff = timestamp - this.time;
        // Sometimes, on some browsers, requestAnimationFrame can run backwards. If so, don't update.
        if(timeDiff < 0) {
            this.time = timestamp;
            return;
        }

        advanceTime(timeDiff, timestamp);

        // After calculations, update time
        this.time = timestamp;
    }

    // Ordinarily, timeDiff will be what you want and perfectly adequate.
    // Rarely, you may want direct access to an unfiltered high-res timestamp.
    advanceTime(timeDiff, timestamp) {
    }
}

// An EulerObjectModel tracks variables internally as a JS object. You pass it an initial time
// and a function to calculate a derivative in an object based on a state (variables) in another
// object. This is significantly slower than using arrays when you have a lot of simple variables
// in your state, but is also much easier and more self-explanatory to program and debug.
//
// This simple Euler-based model won't vary the timestep, or even worry about it - it will simply
// update itself according to the timestep given. This will *not* give fully deterministic results
// in most cases, since floating-point arithmetic is *not* exact.
//
// What it does give is, again, simplicity.
class EulerObjectModel extends AbstractModel {
    constructor(initialTime, diffFunction) {
        super(initialTime);
        this.diffFunction = diffFunction;
        this.variables = {}
    }

    get actions() {
        return {};
    }

    takeAction(act) {
        // Need to implement
        throw("Implement me!");
    }

    get variables() {
        return this.variables;
    }

    setVariables(variables) {
        this.variables = variables;
    }

    get diffFunction() {
        return this.diffFunction;
    }

    advanceTime(timeDiff, timestamp) {
        var deriv = this.diffFunction(this.variables, this.timeDiff, this.timestamp);
        var newState = _.clone(this.variables);

        _.forOwn(deriv, function(value, key) {
            newState[key] += timeDiff * value;
        });

        this.variables = newState;
    }
}

class SimpleGameModel extends EulerObjectModel {
    constructor(initialTime) {
        var initialState = {
            burnedout: 0,
            inspired: 20
        };
        var derivative = function(vars, delta, ts) {
            var deriv = {
                burnedout: -1,
                inspired: 1
            };
        }
        super(initialTime, derivative);
        setVariables(initialState);
    }

    get actions() {
        return {
            vacation: {
            },
            project: {
            },
            study: {
            },
            grindwork: {

            }
        };
    }

    takeAction(act) {
        if("vacation" === act) {
            this.variables.inspired += 5;
            this.variables.burnedout -= 5;
        } else if ("project" === act) {
            this.variables.burnedout += 2;
            this.variables.inspired += parseInt(Math.random(3));
        } else if ("study" === act) {
            this.variables.burnedout += 1;
        } else if ("grindwork" === act) {
            this.variables.burnedout += 3;
        } else {
            throw("No such action as '" + act + "'!");
        }
    }
}
