import {combineReducers } from "redux";
import counter from "./counter";

const allReducers = combineReducers({
    counter,
})

export default allReducers;