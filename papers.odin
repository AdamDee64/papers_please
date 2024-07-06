package main

import "core:math/rand"

import rl "vendor:raylib"

Rect :: rl.Rectangle
Color :: rl.Color
Vec2 :: rl.Vector2

Paper :: struct {
    rect : Rect,
    color : Color
}
    
// when a paper is grabbed, we take that paper out of the array and move it to the end so it is drawn last (appears on top)
arrange_papers :: proc(index : int, papers : ^[dynamic]Paper) {
    if index == len(papers) - 1 {return} // if last index page is grabbed, no re-arrangement necessary
    top_sheet := papers[index]
    ordered_remove(papers, index) 
    append(papers, top_sheet)
}

main :: proc() {
    
    WIDTH   :: 800
    HEIGHT  :: 600
    FPS     :: 60
    TITLE : cstring : "Papers, if you please."

    rl.SetTraceLogLevel(rl.TraceLogLevel.ERROR)
    rl.InitWindow(WIDTH, HEIGHT, TITLE)
    rl.SetTargetFPS(FPS)

    // populate an array of papers with random sizes and colors
    papers : [dynamic]Paper

    for i in 0..<100{ 
        using new_paper : Paper = ---

        rect.x = rand.float32() * 300
        rect.y = rand.float32() * 100
        rect.width = rand.float32_range(250, 400)
        rect.height = rand.float32_range(350, 500)

        color.r = u8(rand.int31() % 150 + 50)
        color.g = u8(rand.int31() % 150 + 50)
        color.b = u8(rand.int31() % 150 + 50)
        color.a = 255

        append(&papers, new_paper)
    }

    paper_held_offset : Vec2 = --- 
    paper_is_held := false

    for !rl.WindowShouldClose() {

        if rl.IsMouseButtonPressed(rl.MouseButton(0)) {
            mouse := rl.GetMousePosition()
            for i in 1..=len(papers){
                // because of how drawing works, the last item in the array appears "on top" graphically, 
                // so we check collision with the mouse on every piece of paper in the pile in reverse order
                index := len(papers) - i
                if rl.CheckCollisionPointRec(mouse, papers[index].rect){
                    paper_is_held = true
                    paper_held_offset.x = mouse.x - papers[index].rect.x
                    paper_held_offset.y = mouse.y - papers[index].rect.y
                    arrange_papers(index, &papers)
                    // once we reach our first collision, we stop checking because we only want to hold one piece of paper at a time
                    break
                }
            }
        }

        if rl.IsMouseButtonReleased(rl.MouseButton(0)){
            paper_is_held = false
        }

        if paper_is_held {     
            mouse := rl.GetMousePosition()
            papers[len(papers) - 1].rect.x = mouse.x - paper_held_offset.x
            papers[len(papers) - 1].rect.y = mouse.y - paper_held_offset.y
        }

        rl.BeginDrawing()
        
        rl.ClearBackground(rl.BLACK)
        for &paper in papers{
            using paper
            rl.DrawRectangleRec(rect, color)
        }
            
        rl.EndDrawing()
    }

    rl.CloseWindow()
}