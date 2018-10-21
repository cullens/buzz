import java.util.Arrays;

class Cell implements Comparable {
  float[] vector;
  float cost;
  float inter;
  float fitness;
  float sum_nutrients;
    
  Cell(float[] vector) {
    this.vector = vector;
  }
  
  Cell clone() {
    Cell cell = new Cell(vector);
    cell.cost = cost;
    cell.inter = inter;
    cell.fitness = fitness;
    cell.sum_nutrients = sum_nutrients;
    return cell;
  }
  
  int compareTo(Object obj) {
    Cell cell = (Cell) obj;
    return int((cell.sum_nutrients - sum_nutrients) * 1000000);
  }

}

class BFOA {
  
  int problem_size = 2;
  float[] dimension = {-1, 1};
  float[][] search_space = new float[problem_size][];
  
  int pop_size = 100;
  float step_size = 0.001; 

  int elim_disp_steps = 1; 
  int repro_steps = 4; 

  int chem_steps = 30; 
  int swim_length = 3; 
  float p_eliminate = 0.25; 

  float d_attr = 0.1;
  float w_attr = 0.2;
  float h_rep = d_attr;
  float w_rep = 10;

  PImage food;

  Cell[] cells;

  BFOA(PImage food, int pop_size, int elim_disp_steps, int repro_steps, int chem_steps) {
  
    this.food = food;  
    this.pop_size = pop_size;
    this.elim_disp_steps = elim_disp_steps;
    this.repro_steps = repro_steps;
    this.chem_steps = chem_steps;
    
    cells = new Cell[pop_size];
     
    for (int i = 0; i < problem_size; i++) {
      search_space[i] = dimension;
    }
    
    for (int i = 0; i < pop_size; i++) {
      cells[i] = new Cell(random_vector(search_space));
    }
    
  }
  
  float objective_function(float[] vector) {
    color argb = food.get( (int) (0.5 * (vector[0] + 1) * 640), (int)(0.5 * (vector[1] + 1) * 480) );
    
    int a = (argb >> 24) & 0xFF;
    int r = (argb >> 16) & 0xFF;  
    int g = (argb >> 8) & 0xFF;   
    int b = argb & 0xFF;          
     
    return (0.21 * r + 0.72 * g + 0.07 * b);
  }
  
  float[] random_vector(float[][] minmax) {
    float[] vector = new float[minmax.length];
    
    for (int i = 0; i < minmax.length; i++) {
      vector[i] = random(minmax[i][0], minmax[i][1]);
    }
    
    return vector;
  }

  float[] generate_random_direction() {
    float[][] vector = new float[problem_size][];
    
    for (int i = 0; i < problem_size; i++) {
      vector[i] = dimension;
    }
    
    return random_vector(vector);
  }

  float compute_cell_interaction(Cell cell, float d, float w) {
    float sum = 0.0;
    
    for (Cell other_cell : cells) {
      
      float diff = 0.0;
      
      for (int i = 0; i < problem_size; i++) {
        diff += Math.pow(cell.vector[i] - other_cell.vector[i], 2.0);
      }
      
      sum += d * Math.exp(w * diff);
      
    }
    
    return sum;
  }

  float attract_repel(Cell cell) {
    float attract = compute_cell_interaction(cell, -d_attr, -w_attr);
    float repel = compute_cell_interaction(cell, h_rep, -w_rep);

    return attract + repel;
  }

  Cell evaluate(Cell cell) {
    cell.cost = objective_function(cell.vector);
    cell.inter = attract_repel(cell);
    cell.fitness = cell.cost + cell.inter;
    return cell;
  }

  Cell tumble_cell(Cell cell) {
    float[] step = generate_random_direction();
    float[] vector = new float[search_space.length];
    
    for (int i = 0; i < vector.length; i++) {
 
      vector[i] = cell.vector[i] + step_size * step[i];

      if (vector[i] < search_space[i][0]) {
        vector[i] = search_space[i][0];
      }

      if (vector[i] > search_space[i][1]) {
        vector[i] = search_space[i][1];
      }

    }
    
    return new Cell(vector);
  }
  
  Cell chemotaxis() {    
    Cell best = null;

    for (int j = 0; j < chem_steps; j++) {
      ArrayList<Cell> moved_cells = new ArrayList<Cell>();
      
      for (int cell_idx = 0; cell_idx < cells.length; cell_idx++) {
        Cell cell = cells[cell_idx];
        
        float  sum_nutrients = 0.0;

        cell = evaluate(cell);
        
        if (best == null || cell.cost < best.cost) {
          best = cell;
        }
        
        sum_nutrients += cell.fitness;

        for (int m = 0; m < swim_length; m++) {

          Cell new_cell = tumble_cell(cell);

          new_cell = evaluate(new_cell);

          if (cell.cost < best.cost) {
            best = cell;
          }

          if (new_cell.fitness > cell.fitness) {
            break;
          }

          cell = new_cell;
          sum_nutrients += cell.fitness;

        }

        cell.sum_nutrients = sum_nutrients;
        moved_cells.add(cell);
        
      }
      
      //println(String.format("best chemo=%d f=%f cost=%.015f", j, best.fitness, best.cost));
      
      cells = moved_cells.toArray(new Cell[0]);

    }
    
    return best;
  }

  Cell reproduce() {
  
    Cell best = chemotaxis();
      
    Arrays.sort(cells);
        
    for (int i = 0; i < pop_size / 2; i++) {
      cells[(pop_size / 2) + i] = cells[i].clone(); 
    }


    return best;
  }
  
  void disperse() {
  
    for (Cell cell : cells) {
      if (random(1) <= p_eliminate) {
        cell.vector = random_vector(search_space);
      }
    }

  }

}