// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty;

  define(['js/board-data'], function(Board) {
    return function() {
      var Group, board, groups, history, neighbors, place, playable, prisoners, prop, removeStone, state, suicide, valid;
      state = {
        groups: [],
        history: [],
        prisoners: {
          white: 0,
          black: 0
        },
        nextMove: 'black',
        board: Board()
      };
      groups = state.groups, history = state.history, prisoners = state.prisoners, board = state.board;
      valid = function(coord, shouldBeEmpty) {
        if (shouldBeEmpty == null) {
          shouldBeEmpty = true;
        }
        if (Board.offBoard(coord)) {
          return false;
        }
        return shouldBeEmpty === ((board.get(coord)) == null);
      };
      neighbors = function(coord, empty) {
        var nbs, x, y, _i, _len, _ref;
        if (empty == null) {
          empty = true;
        }
        nbs = [];
        x = coord[0], y = coord[1];
        _ref = [[x, y - 1], [x + 1, y], [x, y + 1], [x - 1, y]];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          coord = _ref[_i];
          if (valid(coord, empty)) {
            nbs.push((empty ? coord : board.get(coord)));
          }
        }
        return nbs;
      };
      removeStone = (function(_this) {
        return function(coord) {
          _this.onRemoveStone(coord);
          return board.set(coord, void 0);
        };
      })(this);
      suicide = function(color, coord) {
        var neighbor, _i, _len, _ref;
        if (neighbors(coord, true).length > 0) {
          return false;
        }
        _ref = neighbors(coord, false);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          neighbor = _ref[_i];
          if (neighbor.color === color) {
            if (groups[neighbor.groupNum].liberties() > 1) {
              return false;
            }
          } else {
            if (groups[neighbor.groupNum].liberties() === 1) {
              return false;
            }
          }
        }
        return true;
      };
      playable = function(color, coord) {
        var last;
        if (!(color = state.nextMove)) {
          return false;
        }
        if (!valid(coord)) {
          return false;
        }
        if (suicide(color, coord)) {
          return false;
        }
        if (history.length > 0) {
          last = history[history.length - 1];
          if (last.ko && last.ko[0] === coord[0] && last.ko[1] === coord[1]) {
            return false;
          }
        }
        return true;
      };
      Group = function(color, coord) {
        var group;
        group = [coord];
        group.color = color;
        group.num = groups.length;
        group.liberties = function() {
          var liberties, stone, _i, _len;
          liberties = [];
          for (_i = 0, _len = this.length; _i < _len; _i++) {
            stone = this[_i];
            liberties = Board.unionCoord(liberties, neighbors(stone));
          }
          return liberties.length;
        };
        group.test = (function(_this) {
          return function() {
            var stone, _i, _len;
            if (group.liberties() === 0) {
              for (_i = 0, _len = group.length; _i < _len; _i++) {
                stone = group[_i];
                removeStone(stone);
              }
              prisoners[color] += group.length;
              delete groups[group.num];
              return false;
            } else {
              return true;
            }
          };
        })(this);
        return group;
      };
      place = (function(_this) {
        return function(color, coord) {
          var foe, group, n, neighbor, ng, ngNum, record, x, y, _i, _j, _len, _len1, _ref;
          if (playable(color, coord)) {
            x = coord[0], y = coord[1];
            board.set(coord, {
              color: color,
              groupNum: groups.length
            });
            _this.onAddStone(color, coord);
            record = {
              color: color,
              x: x,
              y: y
            };
            group = Group(color, coord);
            _ref = neighbors(coord, false);
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              neighbor = _ref[_i];
              if (neighbor.color === color) {
                ngNum = neighbor.groupNum;
                if (group.num !== ngNum) {
                  ng = groups[ngNum];
                  for (_j = 0, _len1 = ng.length; _j < _len1; _j++) {
                    n = ng[_j];
                    board.get(n).groupNum = groups.length;
                  }
                  group.push.apply(group, ng);
                  delete groups[ngNum];
                }
              } else {
                foe = groups[neighbor.groupNum];
                if ((foe != null ? foe.test() : void 0) === false) {
                  record.kills = foe;
                  if (foe.length === 1) {
                    record.ko = foe[0];
                  }
                }
              }
            }
            groups.push(group);
            history.push(record);
            return state.nextMove = Board.switchColor(state.nextMove);
          }
        };
      })(this);
      this.onRemoveStone = function() {};
      this.onAddStone = function() {};
      this.playerMove = function(color, coord) {
        return place(color, coord);
      };
      this.onValidatedMove = function() {};
      this.checkValidMove = function(color, coord) {
        if (playable(color, coord)) {
          this.onValidatedMove(coord);
          return true;
        } else {
          this.onValidatedMove([-1, -1]);
          return false;
        }
      };
      this.getState = function() {
        return _.clone(state);
      };
      for (prop in this) {
        if (!__hasProp.call(this, prop)) continue;
        this[prop] = this[prop].bind(this);
      }
      return this;
    };
  });

}).call(this);
