package game

import "core:fmt"
import "core:log"
import "core:os"
import "core:time"
import "vendor:sdl3"

main :: proc() {
  logger := log.create_console_logger()
  context.logger = logger
  defer log.destroy_console_logger(logger)

  log.debug("Starting game")

  game := new(Game)
  err := game_init(game)
  if err != nil {
    log.fatalf("Failed to initialize the game: %v", err)
    return
  }

  log.debug("Game initialized")

  game_run_main_loop(game)

  game_destroy(game)
}
