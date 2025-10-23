
-- Create training_steps table for detailed step tracking
CREATE TABLE public.training_steps (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  training_plan_id UUID REFERENCES public.training_plans(id) ON DELETE CASCADE NOT NULL,
  step_number INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP WITH TIME ZONE,
  points_reward INTEGER DEFAULT 10,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Add RLS policies
ALTER TABLE public.training_steps ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own training steps" 
  ON public.training_steps 
  FOR SELECT 
  USING (EXISTS (
    SELECT 1 FROM public.training_plans tp 
    WHERE tp.id = training_plan_id AND tp.user_id = auth.uid()
  ));

CREATE POLICY "Users can create their own training steps" 
  ON public.training_steps 
  FOR INSERT 
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.training_plans tp 
    WHERE tp.id = training_plan_id AND tp.user_id = auth.uid()
  ));

CREATE POLICY "Users can update their own training steps" 
  ON public.training_steps 
  FOR UPDATE 
  USING (EXISTS (
    SELECT 1 FROM public.training_plans tp 
    WHERE tp.id = training_plan_id AND tp.user_id = auth.uid()
  ));

-- Create user_rewards table for gamification
CREATE TABLE public.user_rewards (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  total_points INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_activity DATE,
  badges JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id)
);

-- Add RLS policies for user_rewards
ALTER TABLE public.user_rewards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own rewards" 
  ON public.user_rewards 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own rewards" 
  ON public.user_rewards 
  FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own rewards" 
  ON public.user_rewards 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Add trigger for updated_at
CREATE TRIGGER update_training_steps_updated_at 
    BEFORE UPDATE ON public.training_steps 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_rewards_updated_at 
    BEFORE UPDATE ON public.user_rewards 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
