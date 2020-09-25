/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package br.com.zup.beagle.sample.components

import android.content.Context
import android.view.View
import android.widget.LinearLayout
import br.com.zup.beagle.sample.R
import kotlinx.android.synthetic.main.custom_component.view.btn_view
import kotlinx.android.synthetic.main.custom_component.view.btn_view_gone
import kotlinx.android.synthetic.main.custom_component.view.linear_components

class CustomLinear(context: Context): LinearLayout(context){



    init {
        View.inflate(context, R.layout.custom_component, this)
    }

    fun addChild(view: View){
        linear_components.addView(view)
    }

    fun buttonGone(){
        btn_view_gone.setOnClickListener {
            linear_components.visibility = View.GONE
        }
    }

    fun linearVisibility(boolean: Boolean){
        if (boolean){
            linear_components.visibility = View.VISIBLE
        } else{
            linear_components.visibility = View.GONE
        }
    }

    fun selfVisibility(boolean: Boolean){
        if (boolean){
            visibility = View.VISIBLE
        } else{
            visibility = View.GONE
        }
    }

    fun buttonView(){
        btn_view.setOnClickListener {
            linear_components.visibility = View.VISIBLE
        }
    }

}