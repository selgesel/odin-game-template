package game

import "core:math"
import "core:fmt"
import "core:time"
import "vendor:sdl3"

WINDOW_TITLE :: "My Awesome Game"
WINDOW_WIDTH :: 1366
WINDOW_HEIGHT :: 768
TARGET_FPS :: 60.0
FIXED_UPDATES_PER_SECOND :: 60.0

Game_InitError :: struct {
  message: string,
}

Game_Error :: union {
  Game_InitError,
}

Game :: struct {
  window: ^sdl3.Window,
  renderer: ^sdl3.Renderer,

  last_update_time: time.Tick,
  last_fixed_update_time: time.Tick,
  last_render_time: time.Tick,

  color: sdl3.FColor,
  color_change_per_update: sdl3.FColor,
}

game_init :: proc(game: ^Game) -> Game_Error {
  game.color = {1, 0, 0, 1}
  game.color_change_per_update = {0.00005, .0002, 0.0004, 0}

  if !sdl3.Init(sdl3.INIT_VIDEO) {
    err_msg := fmt.tprintfln("Failed to initialize SDL3: %v", sdl3.GetError())
    return Game_InitError { message = err_msg }
  }

  window: ^sdl3.Window
  renderer: ^sdl3.Renderer
  if !sdl3.CreateWindowAndRenderer(cstring(WINDOW_TITLE), WINDOW_WIDTH, WINDOW_HEIGHT, sdl3.WINDOW_RESIZABLE, &window, &renderer) {
    err_msg := fmt.tprintfln("Failed to create the window or the renderer: %v", sdl3.GetError())
    return Game_InitError { message = err_msg }
  }

  game.window = window
  game.renderer = renderer
  return nil
}

game_run_main_loop :: proc(game: ^Game) {
  game.last_update_time = time.tick_now()
  game.last_fixed_update_time = time.tick_now()
  game.last_render_time = time.tick_now()

  frame_render_delay := 1000.0 / TARGET_FPS
  fixed_update_delay := 1000.0 / FIXED_UPDATES_PER_SECOND

  event: sdl3.Event
  for {
    has_event := sdl3.PollEvent(&event)

    if has_event {
      if event.type == .QUIT {
        break
      }
    }

    update_elapsed := time.duration_milliseconds(time.tick_since(game.last_update_time))
    fixed_update_elapsed := time.duration_milliseconds(time.tick_since(game.last_fixed_update_time))
    render_elapsed := time.duration_milliseconds(time.tick_since(game.last_render_time))

    game_update(game, update_elapsed)

    if fixed_update_elapsed >= fixed_update_delay {
      game_fixed_update(game, fixed_update_elapsed)
      game.last_fixed_update_time = time.tick_now()
    }

    if render_elapsed >= frame_render_delay {
      game_render(game)
      game.last_render_time = time.tick_now()
    }

    game.last_update_time = time.tick_now()
  }
}

game_destroy :: proc(game: ^Game) {
  if game == nil {
    return
  }

  sdl3.DestroyRenderer(game.renderer)
  sdl3.DestroyWindow(game.window)

  free(game)
}

game_update :: proc(game: ^Game, delta: f64) {
  change := game.color_change_per_update * f32(delta)
  game.color += change

  if game.color.r > 1 {
    game.color.r = 1
    game.color_change_per_update.r = -game.color_change_per_update.r
  } else if game.color.r < 0 {
    game.color.r = 0
    game.color_change_per_update.r = -game.color_change_per_update.r
  }

  if game.color.g > 1 {
    game.color.g = 1
    game.color_change_per_update.g = -game.color_change_per_update.g
  } else if game.color.g < 0 {
    game.color.g = 0
    game.color_change_per_update.g = -game.color_change_per_update.g
  }

  if game.color.b > 1 {
    game.color.b = 1
    game.color_change_per_update.b = -game.color_change_per_update.b
  } else if game.color.b < 0 {
    game.color.b = 0
    game.color_change_per_update.b = -game.color_change_per_update.b
  }

  if game.color.a > 1 {
    game.color.a = 1
    game.color_change_per_update.a = -game.color_change_per_update.a
  } else if game.color.a < 0 {
    game.color.a = 0
    game.color_change_per_update.a = -game.color_change_per_update.a
  }
}

game_fixed_update :: proc(game: ^Game, delta: f64) {
}

game_render :: proc(game: ^Game) {
  sdl3.SetRenderDrawColorFloat(game.renderer, game.color.r, game.color.g, game.color.b, game.color.a)
  sdl3.RenderClear(game.renderer)
  sdl3.RenderPresent(game.renderer)
}
