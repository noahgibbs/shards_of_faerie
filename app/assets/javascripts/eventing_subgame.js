// Various JS for EventingSubgame

window.EventingSubgame = {
    activate: function(model) {
        window.EventingSubgame.models.push(model);
        if(model.setupActionUI) {
            model.setupActionUI();
        }
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

        // Have to reactivate or we don't get the next animation frame
        window.EventingSubgame.startHandler();
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

    update(timestamp) {
        var timeDiff = timestamp - this.time;
        // Sometimes, on some browsers, requestAnimationFrame can run backwards. If so, don't update.
        if(timeDiff < 0) {
            this.time = timestamp;
            return;
        }
        timeDiff *= 0.001; // This is in milliseconds, convert to seconds

        this.advanceTime(timeDiff, timestamp);

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
//
// EulerObjectModel defines actions, and can set up a simple default UI based on them using
// setupActionUI. A more developed interface will want to override setupActionUI instead of
// using the parent class, but you can prototype quickly by not overriding it and playing with
// the model mathematically before making it look and feel better.
class EulerObjectModel extends AbstractModel {
    constructor(initialTime, diffFunction) {
        super(initialTime);
        this.diffFunction = diffFunction;
        this.vars = {}
    }

    get actions() {
        return {};
    }

    takeAction(act) {
        // Need to implement
        throw("Implement me!");
    }

    setupActionUI() {
        var acts = this.actions;
        _.forOwn(acts, function(action_name, action_obj) {
            $(".actions").append("<div class='default_action'>" + action_obj.description + "</div>");
        });
        var vars = this.variables;
        _.forOwn(vars, function(var_name, var_value) {
            $(".statistics").append("<div class='default_statistic'>" + var_name + "</div>")
        });
    }

    get variables() {
        return this.vars;
    }

    setVariables(variables) {
        this.vars = variables;
    }

    advanceTime(timeDiff, timestamp) {
        var deriv = this.diffFunction(this.variables, this.timeDiff, this.timestamp);
        var newState = _.clone(this.variables);

        _.forOwn(deriv, function(value, key) {
            newState[key] += timeDiff * value;
        });

        this.setVariables(newState);
    }
}

class SimpleGameModel extends EulerObjectModel {
    constructor(initialTime) {
        var initialState = {
            exhausted: 0,
            strong: 0,
            fashionable: 0,
        };
        var derivative = function(vars, delta, ts) {
            var deriv = {
                exhausted: vars.exhausted > 0 ? -1.0 : 0.0,
                placeholder: 0.0
            };
            return deriv;
        }
        super(initialTime, derivative);
        this.setVariables(initialState);
    }

    get actions() {
        return {
            strength_training: {
                description: "Strength Training"
            },
            posing: {
                description: "Posing"
            },
        };
    }

    takeAction(act) {
        if("strength_training" === act) {
            this.variables.exhausted += 5;
            this.variables.strong += 2;
        } else if ("posing" === act) {
            this.variables.exhausted += 2;
            this.variables.fashionable += parseInt(Math.random() * 3.0);
        } else {
            throw("No such action as '" + act + "'!");
        }
    }
}
