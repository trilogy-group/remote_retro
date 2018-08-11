import {
  reducer,
  actions as actionCreators,
} from "../../web/static/js/redux/retro"

import stageConfigs from "../../web/static/js/configs/stage_configs"
import STAGES from "../../web/static/js/configs/stages"

const { PRIME_DIRECTIVE } = STAGES

describe("retro reducer", () => {
  describe("unhandled actions", () => {
    describe("when there is an empty action", () => {
      describe("when no initial state is passed", () => {
        it("should return an initial state of null", () => {
          expect(reducer(undefined, { type: "unknown" })).to.equal(null)
        })
      })

      describe("when an initial state is passed", () => {
        const initialState = {
          stage: "derp",
          inserted_at: "2017-04-14T17:30:10",
        }

        it("should return that initial state", () => {
          expect(reducer(initialState, {})).to.equal(initialState)
        })
      })
    })
  })

  describe("handled actions", () => {
    describe("when invoked with a SET_INITIAL_STATE action", () => {
      it("returns an object based on the initialState, but stripped of attributes containing arrays", () => {
        const actionInitialState = {
          inserted_at: "holy mother of jeebus",
          stage: "prime-directive",
          facilitator_id: 98,
          ideas: [],
          votes: [],
        }
        const action = { type: "SET_INITIAL_STATE", initialState: actionInitialState }
        expect(reducer(undefined, action)).to.eql({
          inserted_at: "holy mother of jeebus",
          stage: "prime-directive",
          facilitator_id: 98,
        })
      })
    })
  })
})

describe("action creators", () => {
  describe("updateStage", () => {
    it("creates an action to update the retro's stage", () => {
      const newStage = "newSlang"

      expect(actionCreators.updateStage(newStage)).to.deep.equal({
        type: "UPDATE_STAGE",
        stage: newStage,
        stageConfigs,
      })
    })
  })

  describe("setInitialState", () => {
    it("creates an action to set the retro's initial state", () => {
      const initialState = { stage: PRIME_DIRECTIVE, inserted_at: "2017-04-14T17:30:10" }

      expect(actionCreators.setInitialState(initialState)).to.deep.equal({
        type: "SET_INITIAL_STATE",
        initialState,
      })
    })
  })
})
