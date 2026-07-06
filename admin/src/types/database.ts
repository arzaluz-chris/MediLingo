export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  medilingo: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      achievements: {
        Row: {
          category: string
          created_at: string
          description: string
          gem_reward: number
          icon_url: string | null
          id: string
          is_secret: boolean
          requirement: Json
          slug: string
          sort_order: number
          title: string
          xp_reward: number
        }
        Insert: {
          category?: string
          created_at?: string
          description: string
          gem_reward?: number
          icon_url?: string | null
          id?: string
          is_secret?: boolean
          requirement: Json
          slug: string
          sort_order?: number
          title: string
          xp_reward?: number
        }
        Update: {
          category?: string
          created_at?: string
          description?: string
          gem_reward?: number
          icon_url?: string | null
          id?: string
          is_secret?: boolean
          requirement?: Json
          slug?: string
          sort_order?: number
          title?: string
          xp_reward?: number
        }
        Relationships: []
      }
      admin_users: {
        Row: {
          created_at: string
          email: string
          role: string
          user_id: string
        }
        Insert: {
          created_at?: string
          email: string
          role?: string
          user_id: string
        }
        Update: {
          created_at?: string
          email?: string
          role?: string
          user_id?: string
        }
        Relationships: []
      }
      ai_conversations: {
        Row: {
          ai_model: string
          ai_provider: string
          completed_at: string | null
          conversation_type: string
          created_at: string
          duration_ms: number | null
          feedback: Json | null
          id: string
          message_count: number | null
          scenario: Json
          score: number | null
          status: string
          user_id: string
          xp_earned: number
        }
        Insert: {
          ai_model?: string
          ai_provider?: string
          completed_at?: string | null
          conversation_type?: string
          created_at?: string
          duration_ms?: number | null
          feedback?: Json | null
          id?: string
          message_count?: number | null
          scenario?: Json
          score?: number | null
          status?: string
          user_id: string
          xp_earned?: number
        }
        Update: {
          ai_model?: string
          ai_provider?: string
          completed_at?: string | null
          conversation_type?: string
          created_at?: string
          duration_ms?: number | null
          feedback?: Json | null
          id?: string
          message_count?: number | null
          scenario?: Json
          score?: number | null
          status?: string
          user_id?: string
          xp_earned?: number
        }
        Relationships: [
          {
            foreignKeyName: "ai_conversations_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      ai_messages: {
        Row: {
          audio_url: string | null
          content: string
          conversation_id: string
          corrections: Json | null
          created_at: string
          fluency_score: number | null
          grammar_score: number | null
          id: string
          pronunciation_score: number | null
          role: string
          tokens_used: number | null
          vocabulary_score: number | null
        }
        Insert: {
          audio_url?: string | null
          content: string
          conversation_id: string
          corrections?: Json | null
          created_at?: string
          fluency_score?: number | null
          grammar_score?: number | null
          id?: string
          pronunciation_score?: number | null
          role: string
          tokens_used?: number | null
          vocabulary_score?: number | null
        }
        Update: {
          audio_url?: string | null
          content?: string
          conversation_id?: string
          corrections?: Json | null
          created_at?: string
          fluency_score?: number | null
          grammar_score?: number | null
          id?: string
          pronunciation_score?: number | null
          role?: string
          tokens_used?: number | null
          vocabulary_score?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "ai_messages_conversation_id_fkey"
            columns: ["conversation_id"]
            isOneToOne: false
            referencedRelation: "ai_conversations"
            referencedColumns: ["id"]
          },
        ]
      }
      analytics_events: {
        Row: {
          app_version: string | null
          created_at: string
          device_model: string | null
          event_data: Json
          event_name: string
          id: string
          os_version: string | null
          platform: string | null
          session_id: string | null
          user_id: string | null
        }
        Insert: {
          app_version?: string | null
          created_at?: string
          device_model?: string | null
          event_data?: Json
          event_name: string
          id?: string
          os_version?: string | null
          platform?: string | null
          session_id?: string | null
          user_id?: string | null
        }
        Update: {
          app_version?: string | null
          created_at?: string
          device_model?: string | null
          event_data?: Json
          event_name?: string
          id?: string
          os_version?: string | null
          platform?: string | null
          session_id?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "analytics_events_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      audio_clips: {
        Row: {
          accent: string
          created_at: string
          description: string | null
          duration_ms: number
          file_url: string
          id: string
          is_published: boolean
          scenario: string | null
          speaker: string
          speed: string
          tags: string[] | null
          title: string
          transcript_en: string | null
          transcript_es: string | null
        }
        Insert: {
          accent?: string
          created_at?: string
          description?: string | null
          duration_ms?: number
          file_url: string
          id?: string
          is_published?: boolean
          scenario?: string | null
          speaker?: string
          speed?: string
          tags?: string[] | null
          title: string
          transcript_en?: string | null
          transcript_es?: string | null
        }
        Update: {
          accent?: string
          created_at?: string
          description?: string | null
          duration_ms?: number
          file_url?: string
          id?: string
          is_published?: boolean
          scenario?: string | null
          speaker?: string
          speed?: string
          tags?: string[] | null
          title?: string
          transcript_en?: string | null
          transcript_es?: string | null
        }
        Relationships: []
      }
      certificates: {
        Row: {
          course_id: string
          id: string
          issued_at: string
          serial: string
          user_id: string
        }
        Insert: {
          course_id: string
          id?: string
          issued_at?: string
          serial?: string
          user_id: string
        }
        Update: {
          course_id?: string
          id?: string
          issued_at?: string
          serial?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "certificates_course_id_fkey"
            columns: ["course_id"]
            isOneToOne: false
            referencedRelation: "courses"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "certificates_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      challenges: {
        Row: {
          challenged_id: string
          challenged_score: number | null
          challenger_id: string
          challenger_score: number | null
          completed_at: string | null
          created_at: string
          expires_at: string
          id: string
          lesson_id: string | null
          status: string
          winner_id: string | null
          xp_reward: number
        }
        Insert: {
          challenged_id: string
          challenged_score?: number | null
          challenger_id: string
          challenger_score?: number | null
          completed_at?: string | null
          created_at?: string
          expires_at?: string
          id?: string
          lesson_id?: string | null
          status?: string
          winner_id?: string | null
          xp_reward?: number
        }
        Update: {
          challenged_id?: string
          challenged_score?: number | null
          challenger_id?: string
          challenger_score?: number | null
          completed_at?: string | null
          created_at?: string
          expires_at?: string
          id?: string
          lesson_id?: string | null
          status?: string
          winner_id?: string | null
          xp_reward?: number
        }
        Relationships: [
          {
            foreignKeyName: "challenges_challenged_id_fkey"
            columns: ["challenged_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "challenges_challenger_id_fkey"
            columns: ["challenger_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "challenges_lesson_id_fkey"
            columns: ["lesson_id"]
            isOneToOne: false
            referencedRelation: "lessons"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "challenges_winner_id_fkey"
            columns: ["winner_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      content_ratings: {
        Row: {
          created_at: string
          entity_id: string
          entity_type: string
          feedback: string | null
          id: string
          rating: number
          user_id: string
        }
        Insert: {
          created_at?: string
          entity_id: string
          entity_type: string
          feedback?: string | null
          id?: string
          rating: number
          user_id: string
        }
        Update: {
          created_at?: string
          entity_id?: string
          entity_type?: string
          feedback?: string | null
          id?: string
          rating?: number
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "content_ratings_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      courses: {
        Row: {
          category: string
          color_hex: string
          created_at: string
          description: string
          difficulty: string
          estimated_hours: number
          icon_url: string | null
          id: string
          is_featured: boolean
          is_premium: boolean
          is_published: boolean
          published_at: string | null
          short_desc: string
          slug: string
          sort_order: number
          target_role: string[] | null
          title: string
          updated_at: string
        }
        Insert: {
          category?: string
          color_hex?: string
          created_at?: string
          description?: string
          difficulty?: string
          estimated_hours?: number
          icon_url?: string | null
          id?: string
          is_featured?: boolean
          is_premium?: boolean
          is_published?: boolean
          published_at?: string | null
          short_desc?: string
          slug: string
          sort_order?: number
          target_role?: string[] | null
          title: string
          updated_at?: string
        }
        Update: {
          category?: string
          color_hex?: string
          created_at?: string
          description?: string
          difficulty?: string
          estimated_hours?: number
          icon_url?: string | null
          id?: string
          is_featured?: boolean
          is_premium?: boolean
          is_published?: boolean
          published_at?: string | null
          short_desc?: string
          slug?: string
          sort_order?: number
          target_role?: string[] | null
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      daily_quests: {
        Row: {
          created_at: string
          description: string
          gem_reward: number
          id: string
          is_active: boolean
          quest_type: string
          target_value: number
          title: string
          xp_reward: number
        }
        Insert: {
          created_at?: string
          description: string
          gem_reward?: number
          id?: string
          is_active?: boolean
          quest_type: string
          target_value: number
          title: string
          xp_reward?: number
        }
        Update: {
          created_at?: string
          description?: string
          gem_reward?: number
          id?: string
          is_active?: boolean
          quest_type?: string
          target_value?: number
          title?: string
          xp_reward?: number
        }
        Relationships: []
      }
      exercise_attempts: {
        Row: {
          created_at: string
          exercise_id: string
          hearts_lost: number
          id: string
          is_correct: boolean
          lesson_id: string
          metadata: Json | null
          time_spent_ms: number
          user_answer: string | null
          user_id: string
          xp_earned: number
        }
        Insert: {
          created_at?: string
          exercise_id: string
          hearts_lost?: number
          id?: string
          is_correct: boolean
          lesson_id: string
          metadata?: Json | null
          time_spent_ms?: number
          user_answer?: string | null
          user_id: string
          xp_earned?: number
        }
        Update: {
          created_at?: string
          exercise_id?: string
          hearts_lost?: number
          id?: string
          is_correct?: boolean
          lesson_id?: string
          metadata?: Json | null
          time_spent_ms?: number
          user_answer?: string | null
          user_id?: string
          xp_earned?: number
        }
        Relationships: [
          {
            foreignKeyName: "exercise_attempts_exercise_id_fkey"
            columns: ["exercise_id"]
            isOneToOne: false
            referencedRelation: "exercises"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "exercise_attempts_lesson_id_fkey"
            columns: ["lesson_id"]
            isOneToOne: false
            referencedRelation: "lessons"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "exercise_attempts_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      exercise_options: {
        Row: {
          created_at: string
          exercise_id: string
          id: string
          is_correct: boolean
          match_pair_id: string | null
          option_audio_url: string | null
          option_image_url: string | null
          option_text: string
          sort_order: number
        }
        Insert: {
          created_at?: string
          exercise_id: string
          id?: string
          is_correct?: boolean
          match_pair_id?: string | null
          option_audio_url?: string | null
          option_image_url?: string | null
          option_text: string
          sort_order?: number
        }
        Update: {
          created_at?: string
          exercise_id?: string
          id?: string
          is_correct?: boolean
          match_pair_id?: string | null
          option_audio_url?: string | null
          option_image_url?: string | null
          option_text?: string
          sort_order?: number
        }
        Relationships: [
          {
            foreignKeyName: "exercise_options_exercise_id_fkey"
            columns: ["exercise_id"]
            isOneToOne: false
            referencedRelation: "exercises"
            referencedColumns: ["id"]
          },
        ]
      }
      exercises: {
        Row: {
          correct_answer: string | null
          created_at: string
          difficulty: string
          exercise_type: string
          explanation: string | null
          explanation_es: string | null
          hint: string | null
          id: string
          is_published: boolean
          lesson_id: string
          metadata: Json
          prompt: string
          prompt_audio_url: string | null
          prompt_image_url: string | null
          sort_order: number
          updated_at: string
          xp_reward: number
        }
        Insert: {
          correct_answer?: string | null
          created_at?: string
          difficulty?: string
          exercise_type: string
          explanation?: string | null
          explanation_es?: string | null
          hint?: string | null
          id?: string
          is_published?: boolean
          lesson_id: string
          metadata?: Json
          prompt: string
          prompt_audio_url?: string | null
          prompt_image_url?: string | null
          sort_order?: number
          updated_at?: string
          xp_reward?: number
        }
        Update: {
          correct_answer?: string | null
          created_at?: string
          difficulty?: string
          exercise_type?: string
          explanation?: string | null
          explanation_es?: string | null
          hint?: string | null
          id?: string
          is_published?: boolean
          lesson_id?: string
          metadata?: Json
          prompt?: string
          prompt_audio_url?: string | null
          prompt_image_url?: string | null
          sort_order?: number
          updated_at?: string
          xp_reward?: number
        }
        Relationships: [
          {
            foreignKeyName: "exercises_lesson_id_fkey"
            columns: ["lesson_id"]
            isOneToOne: false
            referencedRelation: "lessons"
            referencedColumns: ["id"]
          },
        ]
      }
      flashcard_reviews: {
        Row: {
          created_at: string
          id: string
          new_ease: number
          new_interval: number
          previous_ease: number
          previous_interval: number
          quality: number
          time_spent_ms: number
          user_id: string
          vocabulary_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          new_ease?: number
          new_interval?: number
          previous_ease?: number
          previous_interval?: number
          quality: number
          time_spent_ms?: number
          user_id: string
          vocabulary_id: string
        }
        Update: {
          created_at?: string
          id?: string
          new_ease?: number
          new_interval?: number
          previous_ease?: number
          previous_interval?: number
          quality?: number
          time_spent_ms?: number
          user_id?: string
          vocabulary_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "flashcard_reviews_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "flashcard_reviews_vocabulary_id_fkey"
            columns: ["vocabulary_id"]
            isOneToOne: false
            referencedRelation: "vocabulary"
            referencedColumns: ["id"]
          },
        ]
      }
      friendships: {
        Row: {
          accepted_at: string | null
          created_at: string
          friend_id: string
          id: string
          status: string
          user_id: string
        }
        Insert: {
          accepted_at?: string | null
          created_at?: string
          friend_id: string
          id?: string
          status?: string
          user_id: string
        }
        Update: {
          accepted_at?: string | null
          created_at?: string
          friend_id?: string
          id?: string
          status?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "friendships_friend_id_fkey"
            columns: ["friend_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "friendships_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      league_members: {
        Row: {
          demoted: boolean
          id: string
          league_id: string
          promoted: boolean
          rank: number | null
          user_id: string
          weekly_xp: number
        }
        Insert: {
          demoted?: boolean
          id?: string
          league_id: string
          promoted?: boolean
          rank?: number | null
          user_id: string
          weekly_xp?: number
        }
        Update: {
          demoted?: boolean
          id?: string
          league_id?: string
          promoted?: boolean
          rank?: number | null
          user_id?: string
          weekly_xp?: number
        }
        Relationships: [
          {
            foreignKeyName: "league_members_league_id_fkey"
            columns: ["league_id"]
            isOneToOne: false
            referencedRelation: "leagues"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "league_members_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      leagues: {
        Row: {
          created_at: string
          id: string
          is_active: boolean
          max_members: number
          tier: string
          week_end: string
          week_start: string
        }
        Insert: {
          created_at?: string
          id?: string
          is_active?: boolean
          max_members?: number
          tier: string
          week_end: string
          week_start: string
        }
        Update: {
          created_at?: string
          id?: string
          is_active?: boolean
          max_members?: number
          tier?: string
          week_end?: string
          week_start?: string
        }
        Relationships: []
      }
      lesson_vocabulary: {
        Row: {
          lesson_id: string
          sort_order: number
          vocabulary_id: string
        }
        Insert: {
          lesson_id: string
          sort_order?: number
          vocabulary_id: string
        }
        Update: {
          lesson_id?: string
          sort_order?: number
          vocabulary_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "lesson_vocabulary_lesson_id_fkey"
            columns: ["lesson_id"]
            isOneToOne: false
            referencedRelation: "lessons"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "lesson_vocabulary_vocabulary_id_fkey"
            columns: ["vocabulary_id"]
            isOneToOne: false
            referencedRelation: "vocabulary"
            referencedColumns: ["id"]
          },
        ]
      }
      lessons: {
        Row: {
          completion_text: string | null
          created_at: string
          description: string
          difficulty: string
          estimated_minutes: number
          id: string
          intro_text: string | null
          is_premium: boolean
          is_published: boolean
          lesson_type: string
          module_id: string
          slug: string
          sort_order: number
          title: string
          unlock_after: string | null
          updated_at: string
          xp_reward: number
        }
        Insert: {
          completion_text?: string | null
          created_at?: string
          description?: string
          difficulty?: string
          estimated_minutes?: number
          id?: string
          intro_text?: string | null
          is_premium?: boolean
          is_published?: boolean
          lesson_type?: string
          module_id: string
          slug: string
          sort_order?: number
          title: string
          unlock_after?: string | null
          updated_at?: string
          xp_reward?: number
        }
        Update: {
          completion_text?: string | null
          created_at?: string
          description?: string
          difficulty?: string
          estimated_minutes?: number
          id?: string
          intro_text?: string | null
          is_premium?: boolean
          is_published?: boolean
          lesson_type?: string
          module_id?: string
          slug?: string
          sort_order?: number
          title?: string
          unlock_after?: string | null
          updated_at?: string
          xp_reward?: number
        }
        Relationships: [
          {
            foreignKeyName: "lessons_module_id_fkey"
            columns: ["module_id"]
            isOneToOne: false
            referencedRelation: "modules"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "lessons_unlock_after_fkey"
            columns: ["unlock_after"]
            isOneToOne: false
            referencedRelation: "lessons"
            referencedColumns: ["id"]
          },
        ]
      }
      modules: {
        Row: {
          course_id: string
          created_at: string
          description: string
          icon_url: string | null
          id: string
          is_published: boolean
          slug: string
          sort_order: number
          title: string
          unlock_after: string | null
          updated_at: string
        }
        Insert: {
          course_id: string
          created_at?: string
          description?: string
          icon_url?: string | null
          id?: string
          is_published?: boolean
          slug: string
          sort_order?: number
          title: string
          unlock_after?: string | null
          updated_at?: string
        }
        Update: {
          course_id?: string
          created_at?: string
          description?: string
          icon_url?: string | null
          id?: string
          is_published?: boolean
          slug?: string
          sort_order?: number
          title?: string
          unlock_after?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "modules_course_id_fkey"
            columns: ["course_id"]
            isOneToOne: false
            referencedRelation: "courses"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "modules_unlock_after_fkey"
            columns: ["unlock_after"]
            isOneToOne: false
            referencedRelation: "modules"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          avatar_url: string | null
          created_at: string
          daily_goal_xp: number
          display_name: string
          email: string
          english_level: string
          id: string
          is_premium: boolean
          locale: string
          premium_until: string | null
          primary_goal: string
          referral_code: string | null
          referred_by: string | null
          role: string
          specialty: string | null
          timezone: string
          updated_at: string
        }
        Insert: {
          avatar_url?: string | null
          created_at?: string
          daily_goal_xp?: number
          display_name?: string
          email: string
          english_level?: string
          id: string
          is_premium?: boolean
          locale?: string
          premium_until?: string | null
          primary_goal?: string
          referral_code?: string | null
          referred_by?: string | null
          role?: string
          specialty?: string | null
          timezone?: string
          updated_at?: string
        }
        Update: {
          avatar_url?: string | null
          created_at?: string
          daily_goal_xp?: number
          display_name?: string
          email?: string
          english_level?: string
          id?: string
          is_premium?: boolean
          locale?: string
          premium_until?: string | null
          primary_goal?: string
          referral_code?: string | null
          referred_by?: string | null
          role?: string
          specialty?: string | null
          timezone?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "profiles_referred_by_fkey"
            columns: ["referred_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      push_tokens: {
        Row: {
          created_at: string
          device_name: string | null
          id: string
          is_active: boolean
          platform: string
          token: string
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          device_name?: string | null
          id?: string
          is_active?: boolean
          platform: string
          token: string
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          device_name?: string | null
          id?: string
          is_active?: boolean
          platform?: string
          token?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "push_tokens_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      referrals: {
        Row: {
          code: string
          created_at: string
          id: string
          redeemed_at: string | null
          referee_id: string | null
          referrer_id: string
          rewarded_at: string | null
          status: string
        }
        Insert: {
          code: string
          created_at?: string
          id?: string
          redeemed_at?: string | null
          referee_id?: string | null
          referrer_id: string
          rewarded_at?: string | null
          status?: string
        }
        Update: {
          code?: string
          created_at?: string
          id?: string
          redeemed_at?: string | null
          referee_id?: string | null
          referrer_id?: string
          rewarded_at?: string | null
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "referrals_referee_id_fkey"
            columns: ["referee_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "referrals_referrer_id_fkey"
            columns: ["referrer_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      shop_items: {
        Row: {
          category: string
          created_at: string
          description: string
          effect: Json
          icon_url: string | null
          id: string
          is_available: boolean
          max_owned: number | null
          price_coins: number
          price_gems: number
          slug: string
          sort_order: number
          title: string
        }
        Insert: {
          category: string
          created_at?: string
          description: string
          effect?: Json
          icon_url?: string | null
          id?: string
          is_available?: boolean
          max_owned?: number | null
          price_coins?: number
          price_gems?: number
          slug: string
          sort_order?: number
          title: string
        }
        Update: {
          category?: string
          created_at?: string
          description?: string
          effect?: Json
          icon_url?: string | null
          id?: string
          is_available?: boolean
          max_owned?: number | null
          price_coins?: number
          price_gems?: number
          slug?: string
          sort_order?: number
          title?: string
        }
        Relationships: []
      }
      subscriptions: {
        Row: {
          cancelled_at: string | null
          created_at: string
          currency: string | null
          expires_at: string | null
          id: string
          is_trial: boolean
          original_transaction_id: string | null
          plan_type: string
          platform: string
          price_usd: number | null
          product_id: string
          revenue_cat_id: string | null
          starts_at: string
          status: string
          trial_ends_at: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          cancelled_at?: string | null
          created_at?: string
          currency?: string | null
          expires_at?: string | null
          id?: string
          is_trial?: boolean
          original_transaction_id?: string | null
          plan_type?: string
          platform: string
          price_usd?: number | null
          product_id: string
          revenue_cat_id?: string | null
          starts_at?: string
          status?: string
          trial_ends_at?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          cancelled_at?: string | null
          created_at?: string
          currency?: string | null
          expires_at?: string | null
          id?: string
          is_trial?: boolean
          original_transaction_id?: string | null
          plan_type?: string
          platform?: string
          price_usd?: number | null
          product_id?: string
          revenue_cat_id?: string | null
          starts_at?: string
          status?: string
          trial_ends_at?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "subscriptions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_achievements: {
        Row: {
          achievement_id: string
          id: string
          notified: boolean
          unlocked_at: string
          user_id: string
        }
        Insert: {
          achievement_id: string
          id?: string
          notified?: boolean
          unlocked_at?: string
          user_id: string
        }
        Update: {
          achievement_id?: string
          id?: string
          notified?: boolean
          unlocked_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_achievements_achievement_id_fkey"
            columns: ["achievement_id"]
            isOneToOne: false
            referencedRelation: "achievements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_achievements_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_daily_quests: {
        Row: {
          completed_at: string | null
          created_at: string
          current_value: number
          id: string
          is_completed: boolean
          quest_date: string
          quest_id: string
          user_id: string
        }
        Insert: {
          completed_at?: string | null
          created_at?: string
          current_value?: number
          id?: string
          is_completed?: boolean
          quest_date?: string
          quest_id: string
          user_id: string
        }
        Update: {
          completed_at?: string | null
          created_at?: string
          current_value?: number
          id?: string
          is_completed?: boolean
          quest_date?: string
          quest_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_daily_quests_quest_id_fkey"
            columns: ["quest_id"]
            isOneToOne: false
            referencedRelation: "daily_quests"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_daily_quests_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_inventory: {
        Row: {
          acquired_at: string
          id: string
          is_equipped: boolean
          item_id: string
          quantity: number
          user_id: string
        }
        Insert: {
          acquired_at?: string
          id?: string
          is_equipped?: boolean
          item_id: string
          quantity?: number
          user_id: string
        }
        Update: {
          acquired_at?: string
          id?: string
          is_equipped?: boolean
          item_id?: string
          quantity?: number
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_inventory_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "shop_items"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_inventory_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_onboarding: {
        Row: {
          completed: boolean
          completed_at: string | null
          created_at: string
          selected_course_id: string | null
          step_completed: number
          user_id: string
        }
        Insert: {
          completed?: boolean
          completed_at?: string | null
          created_at?: string
          selected_course_id?: string | null
          step_completed?: number
          user_id: string
        }
        Update: {
          completed?: boolean
          completed_at?: string | null
          created_at?: string
          selected_course_id?: string | null
          step_completed?: number
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_onboarding_selected_course_id_fkey"
            columns: ["selected_course_id"]
            isOneToOne: false
            referencedRelation: "courses"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_onboarding_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_progress: {
        Row: {
          attempts: number
          best_score: number | null
          completed_at: string | null
          created_at: string
          entity_id: string
          entity_type: string
          id: string
          last_active_at: string
          score: number | null
          started_at: string | null
          status: string
          user_id: string
          xp_earned: number
        }
        Insert: {
          attempts?: number
          best_score?: number | null
          completed_at?: string | null
          created_at?: string
          entity_id: string
          entity_type: string
          id?: string
          last_active_at?: string
          score?: number | null
          started_at?: string | null
          status?: string
          user_id: string
          xp_earned?: number
        }
        Update: {
          attempts?: number
          best_score?: number | null
          completed_at?: string | null
          created_at?: string
          entity_id?: string
          entity_type?: string
          id?: string
          last_active_at?: string
          score?: number | null
          started_at?: string | null
          status?: string
          user_id?: string
          xp_earned?: number
        }
        Relationships: [
          {
            foreignKeyName: "user_progress_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_settings: {
        Row: {
          auto_play_audio: boolean
          dark_mode: string
          haptics_enabled: boolean
          notifications_enabled: boolean
          playback_speed: number
          reminder_time: string | null
          sound_enabled: boolean
          updated_at: string
          user_id: string
        }
        Insert: {
          auto_play_audio?: boolean
          dark_mode?: string
          haptics_enabled?: boolean
          notifications_enabled?: boolean
          playback_speed?: number
          reminder_time?: string | null
          sound_enabled?: boolean
          updated_at?: string
          user_id: string
        }
        Update: {
          auto_play_audio?: boolean
          dark_mode?: string
          haptics_enabled?: boolean
          notifications_enabled?: boolean
          playback_speed?: number
          reminder_time?: string | null
          sound_enabled?: boolean
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_settings_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_stats: {
        Row: {
          ai_conversations: number
          clinical_cases_done: number
          coins: number
          current_league: string
          current_streak: number
          exercises_completed: number
          gems: number
          hearts: number
          hearts_last_refill: string
          hearts_max: number
          lessons_completed: number
          level: number
          longest_streak: number
          perfect_lessons: number
          streak_freeze_count: number
          streak_last_date: string | null
          time_spent_minutes: number
          total_xp: number
          updated_at: string
          user_id: string
          weekly_xp: number
          words_learned: number
        }
        Insert: {
          ai_conversations?: number
          clinical_cases_done?: number
          coins?: number
          current_league?: string
          current_streak?: number
          exercises_completed?: number
          gems?: number
          hearts?: number
          hearts_last_refill?: string
          hearts_max?: number
          lessons_completed?: number
          level?: number
          longest_streak?: number
          perfect_lessons?: number
          streak_freeze_count?: number
          streak_last_date?: string | null
          time_spent_minutes?: number
          total_xp?: number
          updated_at?: string
          user_id: string
          weekly_xp?: number
          words_learned?: number
        }
        Update: {
          ai_conversations?: number
          clinical_cases_done?: number
          coins?: number
          current_league?: string
          current_streak?: number
          exercises_completed?: number
          gems?: number
          hearts?: number
          hearts_last_refill?: string
          hearts_max?: number
          lessons_completed?: number
          level?: number
          longest_streak?: number
          perfect_lessons?: number
          streak_freeze_count?: number
          streak_last_date?: string | null
          time_spent_minutes?: number
          total_xp?: number
          updated_at?: string
          user_id?: string
          weekly_xp?: number
          words_learned?: number
        }
        Relationships: [
          {
            foreignKeyName: "user_stats_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      vocabulary: {
        Row: {
          category: string
          created_at: string
          definition_en: string
          definition_es: string | null
          difficulty: string
          etymology: string | null
          example_en: string
          example_es: string | null
          id: string
          is_published: boolean
          phonetic: string | null
          pronunciation_url: string | null
          related_words: string[] | null
          tags: string[] | null
          translation_es: string
          updated_at: string
          word: string
        }
        Insert: {
          category?: string
          created_at?: string
          definition_en: string
          definition_es?: string | null
          difficulty?: string
          etymology?: string | null
          example_en: string
          example_es?: string | null
          id?: string
          is_published?: boolean
          phonetic?: string | null
          pronunciation_url?: string | null
          related_words?: string[] | null
          tags?: string[] | null
          translation_es: string
          updated_at?: string
          word: string
        }
        Update: {
          category?: string
          created_at?: string
          definition_en?: string
          definition_es?: string | null
          difficulty?: string
          etymology?: string | null
          example_en?: string
          example_es?: string | null
          id?: string
          is_published?: boolean
          phonetic?: string | null
          pronunciation_url?: string | null
          related_words?: string[] | null
          tags?: string[] | null
          translation_es?: string
          updated_at?: string
          word?: string
        }
        Relationships: []
      }
      vocabulary_mastery: {
        Row: {
          correct_count: number
          created_at: string
          ease_factor: number
          id: string
          incorrect_count: number
          interval_days: number
          last_reviewed_at: string | null
          mastery_level: number
          next_review_at: string | null
          repetitions: number
          updated_at: string
          user_id: string
          vocabulary_id: string
        }
        Insert: {
          correct_count?: number
          created_at?: string
          ease_factor?: number
          id?: string
          incorrect_count?: number
          interval_days?: number
          last_reviewed_at?: string | null
          mastery_level?: number
          next_review_at?: string | null
          repetitions?: number
          updated_at?: string
          user_id: string
          vocabulary_id: string
        }
        Update: {
          correct_count?: number
          created_at?: string
          ease_factor?: number
          id?: string
          incorrect_count?: number
          interval_days?: number
          last_reviewed_at?: string | null
          mastery_level?: number
          next_review_at?: string | null
          repetitions?: number
          updated_at?: string
          user_id?: string
          vocabulary_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vocabulary_mastery_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vocabulary_mastery_vocabulary_id_fkey"
            columns: ["vocabulary_id"]
            isOneToOne: false
            referencedRelation: "vocabulary"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      add_xp: {
        Args: { p_amount: number }
        Returns: {
          ai_conversations: number
          clinical_cases_done: number
          coins: number
          current_league: string
          current_streak: number
          exercises_completed: number
          gems: number
          hearts: number
          hearts_last_refill: string
          hearts_max: number
          lessons_completed: number
          level: number
          longest_streak: number
          perfect_lessons: number
          streak_freeze_count: number
          streak_last_date: string | null
          time_spent_minutes: number
          total_xp: number
          updated_at: string
          user_id: string
          weekly_xp: number
          words_learned: number
        }
        SetofOptions: {
          from: "*"
          to: "user_stats"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      calculate_level: { Args: { total_xp: number }; Returns: number }
      check_achievements: {
        Args: never
        Returns: {
          category: string
          created_at: string
          description: string
          gem_reward: number
          icon_url: string | null
          id: string
          is_secret: boolean
          requirement: Json
          slug: string
          sort_order: number
          title: string
          xp_reward: number
        }[]
        SetofOptions: {
          from: "*"
          to: "achievements"
          isOneToOne: false
          isSetofReturn: true
        }
      }
      consume_heart: { Args: never; Returns: number }
      demote_admin: { Args: { p_email: string }; Returns: boolean }
      get_or_assign_daily_quests: {
        Args: never
        Returns: {
          completed_at: string | null
          created_at: string
          current_value: number
          id: string
          is_completed: boolean
          quest_date: string
          quest_id: string
          user_id: string
        }[]
        SetofOptions: {
          from: "*"
          to: "user_daily_quests"
          isOneToOne: false
          isSetofReturn: true
        }
      }
      get_referral_code: { Args: never; Returns: string }
      issue_certificate: {
        Args: { p_course_id: string }
        Returns: {
          course_id: string
          id: string
          issued_at: string
          serial: string
          user_id: string
        }
        SetofOptions: {
          from: "*"
          to: "certificates"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      join_league: { Args: never; Returns: string }
      promote_to_admin: { Args: { p_email: string }; Returns: string }
      purchase_item: {
        Args: { p_item_id: string }
        Returns: {
          ai_conversations: number
          clinical_cases_done: number
          coins: number
          current_league: string
          current_streak: number
          exercises_completed: number
          gems: number
          hearts: number
          hearts_last_refill: string
          hearts_max: number
          lessons_completed: number
          level: number
          longest_streak: number
          perfect_lessons: number
          streak_freeze_count: number
          streak_last_date: string | null
          time_spent_minutes: number
          total_xp: number
          updated_at: string
          user_id: string
          weekly_xp: number
          words_learned: number
        }
        SetofOptions: {
          from: "*"
          to: "user_stats"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      record_activity: {
        Args: { p_activity: string; p_amount: number }
        Returns: {
          ai_conversations: number
          clinical_cases_done: number
          coins: number
          current_league: string
          current_streak: number
          exercises_completed: number
          gems: number
          hearts: number
          hearts_last_refill: string
          hearts_max: number
          lessons_completed: number
          level: number
          longest_streak: number
          perfect_lessons: number
          streak_freeze_count: number
          streak_last_date: string | null
          time_spent_minutes: number
          total_xp: number
          updated_at: string
          user_id: string
          weekly_xp: number
          words_learned: number
        }
        SetofOptions: {
          from: "*"
          to: "user_stats"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      record_lesson_completion: {
        Args: {
          p_exercise_count: number
          p_lesson_id: string
          p_perfect: boolean
          p_score: number
          p_time_minutes: number
        }
        Returns: {
          ai_conversations: number
          clinical_cases_done: number
          coins: number
          current_league: string
          current_streak: number
          exercises_completed: number
          gems: number
          hearts: number
          hearts_last_refill: string
          hearts_max: number
          lessons_completed: number
          level: number
          longest_streak: number
          perfect_lessons: number
          streak_freeze_count: number
          streak_last_date: string | null
          time_spent_minutes: number
          total_xp: number
          updated_at: string
          user_id: string
          weekly_xp: number
          words_learned: number
        }
        SetofOptions: {
          from: "*"
          to: "user_stats"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      redeem_referral: { Args: { p_code: string }; Returns: boolean }
      refill_hearts: { Args: never; Returns: number }
      rollover_leagues: { Args: never; Returns: number }
      update_quest_progress: {
        Args: { p_increment: number; p_quest_type: string }
        Returns: {
          completed_at: string | null
          created_at: string
          current_value: number
          id: string
          is_completed: boolean
          quest_date: string
          quest_id: string
          user_id: string
        }[]
        SetofOptions: {
          from: "*"
          to: "user_daily_quests"
          isOneToOne: false
          isSetofReturn: true
        }
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  medilingo: {
    Enums: {},
  },
  public: {
    Enums: {},
  },
} as const

