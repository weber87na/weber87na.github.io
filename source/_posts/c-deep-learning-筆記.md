---
title: c# deep learning 筆記
date: 2024-11-08 12:30:44
tags: c#
---
&nbsp;
<!-- more -->

因為練習 c 的關係, 看到有變態用 c 來手寫 Deep Learning, 就玩看看筆記下, 結果連程式碼都沒附真是狠, 希望不要太早陣亡 XD

## Single Input Single Output Neural Network
他第一個例子用天氣來預測 `開心` 或 `難過`, 非常簡單就是 溫度 * 權重 = 預測值

輸入 -> 權重 -> 輸出
input data -> weight -> output (predicted value)

```
#include <stdio.h>

double temperature[] = {12, 23, 50, -10, 16};
double weight = -2;

double single_in_single_out(double input, double weight)
{
    double predicted = input * weight;
    return predicted;
}

int main()
{
    printf("first value %f\n", single_in_single_out(temperature[0] , weight));
    printf("second value %f\n", single_in_single_out(temperature[1] , weight));
    printf("third value %f\n", single_in_single_out(temperature[2] , weight));
    return 0;
}
```

c# 如下, 老生常談這裡一樣要先開 `<AllowUnsafeBlocks>True</AllowUnsafeBlocks>` 這樣寫起來比較有趣

```
double[] temperature = {12, 23, 50, -10, 16};
double weight = -2;

double SingleInSingleOut(double input, double weight)
{
    double predicted = input * weight;
    return predicted;
}

Console.WriteLine("first value {0}" , SingleInSingleOut(temperature[0] , weight));
Console.WriteLine("second value {0}" , SingleInSingleOut(temperature[1] , weight));
Console.WriteLine("third value {0}" , SingleInSingleOut(temperature[1] , weight));
```

## Single Input Multiple Output Neural Network
假如我們知道這個人心情不太美麗, 我們能否計算 溫度 濕度 空氣品質?

Sad * 溫度權重
0.9 * -20

Sad * 濕度權重
0.9 * 95

Sad * 空氣品質權重
0.9 * 201

他程式碼裡的 input_scalar 即 Sad
`Scalar 純量` 只有大小沒有方向的，如數量、距離、速度或溫度

```
#include <stdio.h>

#define Sad 0.9
#define TEMPERATURE_PREDICTION_IDX 0
#define HUMIDITY_PREDICTION_IDX 1
#define AIR_QUALITY_PREDICITION_IDX 2

#define VECTOR_LEN 3

double predicted_results[3];

//溫度權重 濕度權重 空氣品質權重
double weights[3] = {-20 , 95 , 201};

//核心計算
void elementwise_multiply(double input_scalar, double *weight_vector, double *output_vector, int LEN)
{
    for (int i = 0; i < LEN; i++)
    {
        output_vector[i] = input_scalar * weight_vector[i];
    }
}

//包裝函數
void single_in_multiple_out(double input_scalar, double *weight_vector, double *output_vector, int LEN)
{
    elementwise_multiply(input_scalar, weight_vector, output_vector, LEN);
}

int main()
{
    single_in_multiple_out(Sad, weights, predicted_results , VECTOR_LEN);

	//預測值
    printf("predicted temperature is: %f\n", predicted_results[TEMPERATURE_PREDICTION_IDX]);
    printf("predicted humidity is: %f\n", predicted_results[HUMIDITY_PREDICTION_IDX]);
    printf("predicted air quality is: %f\n", predicted_results[AIR_QUALITY_PREDICITION_IDX]);
    return 0;
}
```

c#

```
unsafe
{

    double Sad = 0.9;
    int TemperaturePrecictionIdx = 0;
    int HumidityPrecictionIdx = 1;
    int AirQualityPrecictionIdx = 2;
    int VectorLen = 3;

    double[] PredictedResults = new double[3];

    double[] weights = { -20, 95, 201 };

    void ElementwiseMultiply(double input_scalar, double* weight_vector, double* output_vector, int LEN)
    {
        for (int i = 0; i < LEN; i++)
        {
            output_vector[i] = input_scalar * weight_vector[i];
        }
    }

    void SingleInMultipleOut(double input_scalar, double* weight_vector, double* output_vector, int LEN)
        => ElementwiseMultiply(input_scalar, weight_vector, output_vector, LEN);

    fixed (double* ptrWeights = weights, ptrPredictedResults = PredictedResults)
    {
        SingleInMultipleOut(Sad, ptrWeights, ptrPredictedResults, VectorLen);
    }


    Console.WriteLine("predicted temperature is: {0}", PredictedResults[TemperaturePrecictionIdx]);
    Console.WriteLine("predicted humidity is: {0}", PredictedResults[HumidityPrecictionIdx]);
    Console.WriteLine("predicted air quality is: {0}", PredictedResults[AirQualityPrecictionIdx]);

}
```

## Multiple Input Single Output
(temperature * weight1) + (humidity * weight2) + (air qualtity * weight3) = Sad (預測值)

```
#include <stdio.h>
//特徵數量
#define NUM_OF_INPUTS 3

//計算加權總和
double weighted_sum(double * input , double * weight, int LEN){
	double output;
	for(int i =0 ; i < LEN; i++){
		output += input[i] * weight[i];
	}
	return output;
}

//包裝函數
double multiple_input_single_output(double * input , double * weight, int LEN){
	double predicted_value;
	
	predicted_value = weighted_sum( input , weight,  LEN);
	return predicted_value;
}

//溫度
double temperature[] = {12,23,50,-10,16};

//濕度
double humidity[] = {60,67,50,65,63};

//空氣品質
double air_quality[] = {60,47,167,187,94};

//權重
double weight[] = {-2,2,1};

int main(){
	double training_eg1[] = {temperature[0] , humidity[0],air_quality[0]};
	printf("predcition from the traning example is: %f\r\n", multiple_input_single_output(training_eg1,weight,3));
}
```

c#

```
unsafe
{
    int NumOfInputs = 3;

    double WeightedSm(double* input, double* weight, int len)
    {
        double output = 0;
        for (int i = 0; i < len; i++)
            output += input[i] * weight[i];
        return output;
    }

    double MultipleInputSingleOutput(double* input, double* weight, int len)
    {
        double predictedValue;
        predictedValue = WeightedSm(input, weight, len);
        return predictedValue;
    }

    //溫度
    double[] temperature = { 12, 23, 50, -10, 16 };

    //濕度
    double[] humidity = { 60, 67, 50, 65, 63 };

    //空氣品質
    double[] air_quality = { 60, 47, 167, 187, 94 };

    //權重
    double[] weight = { -2, 2, 1 };


    double[] training_eg1 = { temperature[0], humidity[0], air_quality[0] };

    fixed (double* ptrWeight = weight, ptrTrainingEg1 = training_eg1)
        Console.WriteLine(
            "predcition from the traning example is:{0}",
            MultipleInputSingleOutput(ptrTrainingEg1, ptrWeight, 3)
        );
}
```

## Multiple input Multiple output

這邊算法跟 Multiple Input Single Output 大同小異
只不過 output 變成三個, 這裡每一種 output 的 權重都不相同

```
		temperature		humidity	air quality
SAD		-2				9.5			2.01
SICK	-0.8			7.2			6.3
ACTIVE	-0.5			0.45		0.9
```

```
#include <stdio.h>
#define IN_LEN 3
#define OUT_LEN 3
#define SAD_PREDICTION_IDX 0
#define SICK_PREDICTION_IDX 1
#define ACTIVE_PREDICTION_IDX 2

void matrix_vector_multiply(
    double *input_vector,
    int INPUT_LEN,
    double *output_vector,
    int OUTPUT_LEN,
    double weight_matrix[OUTPUT_LEN][INPUT_LEN])
{

    for (int k = 0; k < OUTPUT_LEN; k++)
    {
        for (int i = 0; i < INPUT_LEN; i++)
        {
            output_vector[k] += input_vector[i] * weight_matrix[k][i];
        }
    }
}

void multiple_input_multiple_output_nn(
    double *input_vector,
    int INPUT_LEN,
    double *output_vector,
    int OUTPUT_LEN,
    double weight_matrix[OUTPUT_LEN][INPUT_LEN])
{
    matrix_vector_multiply(input_vector, INPUT_LEN, output_vector, OUTPUT_LEN, weight_matrix);
}

double predicted_results[3];

double weights[OUT_LEN][IN_LEN] = {
    {-2, 9.5, 2.01},
    {-0.8, 7.2, 6.3},
    {-0.5, 0.45, 0.9},
};

double inputs[IN_LEN] = {30, 87, 110};

int main()
{
    multiple_input_multiple_output_nn(inputs , IN_LEN , predicted_results , OUT_LEN , weights);

    printf("Sad prediction: %f \r\n", predicted_results[0]);
    printf("Sick prediction: %f \r\n", predicted_results[1]);
    printf("Active prediction: %f \r\n", predicted_results[2]);

    return 0;
}
```

c#

```
unsafe
{
    int IN_LEN = 3;
    int OUT_LEN = 3;
    int SAD_PREDICTION_IDX = 0;
    int SICK_PREDICTION_IDX = 1;
    int ACTIVE_PREDICTION_IDX = 2;

    void matrix_vector_multiply(
        double* input_vector,
        int INPUT_LEN,
        double* output_vector,
        int OUTPUT_LEN,
        double[,] weight_matrix)
    {

        for (int k = 0; k < OUTPUT_LEN; k++)
        {
            for (int i = 0; i < INPUT_LEN; i++)
            {
                output_vector[k] += input_vector[i] * weight_matrix[k, i];
            }
        }
    }

    void multiple_input_multiple_output_nn(
        double* input_vector,
        int INPUT_LEN,
        double* output_vector,
        int OUTPUT_LEN,
        double[,] weight_matrix)
    {
        matrix_vector_multiply(input_vector, INPUT_LEN, output_vector, OUTPUT_LEN, weight_matrix);
    }

    double[] predicted_results = new double[3];

    double[,] weights = {
        { -2, 9.5, 2.01},
        { -0.8, 7.2, 6.3},
        { -0.5, 0.45, 0.9}
    };

    double[] inputs = { 30, 87, 110 };

    fixed (double* ptrInputs = inputs, ptrPredictedResults = predicted_results)
    {
        multiple_input_multiple_output_nn(ptrInputs, IN_LEN, ptrPredictedResults, OUT_LEN, weights);

        Console.WriteLine("Sad prediction: {0}", predicted_results[0]);
        Console.WriteLine("Sick prediction: {0}", predicted_results[1]);
        Console.WriteLine("Active prediction: {0}", predicted_results[2]);
    }
}
```

## hidden layer
由 Multiple input Multiple output 延伸, 只不過中間卡一層隱藏層, 先算出隱藏層數值後, 然後再去做一次加權運算最後得到輸出值

```
			temperature		humidity	air quality
hidden[0]			-2			9.5				2.01
hidden[1]			-0.8		7.2				6.3
hidden[2]			-0.5		0.45			0.9
```

```
		hidden[0]	hidden[1]	hidden[2]
SAD			-1			1.15		0.11
SICK		-0.18		0.15		-0.01
ACTIVE		0.25		-0.25		-0.1
```


```
#include <stdio.h>

#define IN_LEN 3
#define OUT_LEN 3
#define HID_LEN 3

void matrix_vector_multiply(
    double *input_vector,
    int INPUT_LEN,
    double *output_vector,
    int OUTPUT_LEN,
    double weight_matrix[OUTPUT_LEN][INPUT_LEN])
{

    for (int k = 0; k < OUTPUT_LEN; k++)
    {
        for (int i = 0; i < INPUT_LEN; i++)
        {
            output_vector[k] += input_vector[i] * weight_matrix[k][i];
        }
    }
}

double hidden_pred_vector[HID_LEN];

void hidden_layer_nn(
    double *input_vector,
    int INPUT_LEN,
    int HIDDEN_LEN,
    double in_to_hid_weights[HIDDEN_LEN][INPUT_LEN],
    int OUTPUT_LEN,
    double hid_to_out_weights[OUTPUT_LEN][HIDDEN_LEN],
    double *output_vector)
{
    matrix_vector_multiply(input_vector, INPUT_LEN, hidden_pred_vector, OUTPUT_LEN, in_to_hid_weights);
    matrix_vector_multiply(hidden_pred_vector, HIDDEN_LEN, output_vector, OUTPUT_LEN, hid_to_out_weights);
}

double predicted_results[3];

double input_to_hidden_weights[HID_LEN][IN_LEN] = {
    {-2, 9.5, 2.01},
    {-0.8, 7.2, 6.3},
    {-0.5, 0.45, 0.9},
};

double hidden_to_output_weights[OUT_LEN][IN_LEN] = {
    {-1, 1.15, 0.11},
    {-0.18, 0.15, -0.01},
    {0.25, -0.25, -0.1},
};

double inputs[IN_LEN] = {30, 87, 110};

int main()
{
    hidden_layer_nn(inputs, IN_LEN, HID_LEN, input_to_hidden_weights, OUT_LEN, hidden_to_output_weights, predicted_results);
    printf("Sad prediction: %f \r\n", predicted_results[0]);
    printf("Sick prediction: %f \r\n", predicted_results[1]);
    printf("Active prediction: %f \r\n", predicted_results[2]);

    return 0;
}
```

c#

```
unsafe
{
    int IN_LEN = 3;
    int OUT_LEN = 3;
    int HID_LEN = 3;

    void matrix_vector_multiply(
        double* input_vector,
        int INPUT_LEN,
        double* output_vector,
        int OUTPUT_LEN,
        double[,] weight_matrix)
    {

        for (int k = 0; k < OUTPUT_LEN; k++)
        {
            for (int i = 0; i < INPUT_LEN; i++)
            {
                output_vector[k] += input_vector[i] * weight_matrix[k, i];
            }
        }
    }


    double[] hidden_pred_vector = new double[HID_LEN];

    void hidden_layer_nn(
        double* input_vector,
        int INPUT_LEN,
        int HIDDEN_LEN,
        double[,] in_to_hid_weights,
        int OUTPUT_LEN,
        double[,] hid_to_out_weights,
        double* output_vector)
    {
        fixed (double* ptrHiddenPredVector = hidden_pred_vector)
        {
            matrix_vector_multiply(input_vector, INPUT_LEN, ptrHiddenPredVector, OUTPUT_LEN, in_to_hid_weights);
            matrix_vector_multiply(ptrHiddenPredVector, HIDDEN_LEN, output_vector, OUTPUT_LEN, hid_to_out_weights);
        }
    }

    double[] predicted_results = new double[3];

    double[,] input_to_hidden_weights = {
        { -2, 9.5, 2.01},
        { -0.8, 7.2, 6.3},
        { -0.5, 0.45, 0.9},
    };

    double[,] hidden_to_output_weights = {
        { -1, 1.15, 0.11},
        { -0.18, 0.15, -0.01},
        { 0.25, -0.25, -0.1},
    };


    double[] inputs = { 30, 87, 110 };
    fixed (double* ptrInputs = inputs , ptrPredictedResults = predicted_results)
    {
        hidden_layer_nn(ptrInputs, IN_LEN, HID_LEN, input_to_hidden_weights, OUT_LEN, hidden_to_output_weights, ptrPredictedResults);
        Console.WriteLine("Sad prediction: {0}", predicted_results[0]);
        Console.WriteLine("Sick prediction: {0}", predicted_results[1]);
        Console.WriteLine("Active prediction: {0}", predicted_results[2]);
    }
}
```

## finding error

predicted_value = input * weight
error = power(predicted_value - expected_value)

weight = 0.8
expected_value = 26
input = 25

predicted_value = 25 * 0.8
error = power( 20 - 26 )
error = 36

實作新增兩隻函數

`double find_error(double input, double weight, double expected_value)`

`double find_error_simple(double yhat, double y)`

```
#include <stdio.h>
#include <math.h>

#define IN_LEN 3
#define OUT_LEN 3
#define HID_LEN 3

void matrix_vector_multiply(
    double *input_vector,
    int INPUT_LEN,
    double *output_vector,
    int OUTPUT_LEN,
    double weight_matrix[OUTPUT_LEN][INPUT_LEN])
{

    for (int k = 0; k < OUTPUT_LEN; k++)
    {
        for (int i = 0; i < INPUT_LEN; i++)
        {
            output_vector[k] += input_vector[i] * weight_matrix[k][i];
        }
    }
}

double hidden_pred_vector[HID_LEN];

void hidden_layer_nn(
    double *input_vector,
    int INPUT_LEN,
    int HIDDEN_LEN,
    double in_to_hid_weights[HIDDEN_LEN][INPUT_LEN],
    int OUTPUT_LEN,
    double hid_to_out_weights[OUTPUT_LEN][HIDDEN_LEN],
    double *output_vector)
{
    matrix_vector_multiply(input_vector, INPUT_LEN, hidden_pred_vector, OUTPUT_LEN, in_to_hid_weights);
    matrix_vector_multiply(hidden_pred_vector, HIDDEN_LEN, output_vector, OUTPUT_LEN, hid_to_out_weights);
}

double find_error(double input, double weight, double expected_value)
{
    return powf(((input * weight) - expected_value), 2);
}

double find_error_simple(double yhat, double y)
{
    return powf((yhat - y), 2);
}

double predicted_results[3];

double input_to_hidden_weights[HID_LEN][IN_LEN] = {
    {-2, 9.5, 2.01},
    {-0.8, 7.2, 6.3},
    {-0.5, 0.45, 0.9},
};

double hidden_to_output_weights[OUT_LEN][IN_LEN] = {
    {-1, 1.15, 0.11},
    {-0.18, 0.15, -0.01},
    {0.25, -0.25, -0.1},
};

double inputs[IN_LEN] = {30, 87, 110};

double expected_values[OUT_LEN] = {600, 10, -90};

int main()
{
    hidden_layer_nn(inputs, IN_LEN, HID_LEN, input_to_hidden_weights, OUT_LEN, hidden_to_output_weights, predicted_results);
    printf("Sad prediction: %f \r\n", predicted_results[0]);
    printf("Sad Error: %f \r\n", find_error_simple(predicted_results[0], expected_values[0]));
    printf("Sick prediction: %f \r\n", predicted_results[1]);
    printf("Sick Error: %f \r\n", find_error_simple(predicted_results[1], expected_values[1]));
    printf("Active prediction: %f \r\n", predicted_results[2]);
    printf("Active Error: %f \r\n", find_error_simple(predicted_results[2], expected_values[2]));

    return 0;
}
```

c#

```
unsafe
{
    int IN_LEN = 3;
    int OUT_LEN = 3;
    int HID_LEN = 3;

    void matrix_vector_multiply(
        double* input_vector,
        int INPUT_LEN,
        double* output_vector,
        int OUTPUT_LEN,
        double[,] weight_matrix)
    {

        for (int k = 0; k < OUTPUT_LEN; k++)
        {
            for (int i = 0; i < INPUT_LEN; i++)
            {
                output_vector[k] += input_vector[i] * weight_matrix[k, i];
            }
        }
    }


    double[] hidden_pred_vector = new double[HID_LEN];

    void hidden_layer_nn(
        double* input_vector,
        int INPUT_LEN,
        int HIDDEN_LEN,
        double[,] in_to_hid_weights,
        int OUTPUT_LEN,
        double[,] hid_to_out_weights,
        double* output_vector)
    {
        fixed (double* ptrHiddenPredVector = hidden_pred_vector)
        {
            matrix_vector_multiply(input_vector, INPUT_LEN, ptrHiddenPredVector, OUTPUT_LEN, in_to_hid_weights);
            matrix_vector_multiply(ptrHiddenPredVector, HIDDEN_LEN, output_vector, OUTPUT_LEN, hid_to_out_weights);
        }
    }

    double find_error(double input, double weight, double expected_value)
    {
        return Math.Pow(((input * weight) - expected_value), 2);
    }

    double find_error_simple(double yhat, double y)
    {
        return Math.Pow((yhat - y), 2);
    }

    void brute_force_learning(
        double input,
        double weight,
        double expected_value,
        double step_amount,
        int itr)
    {
        double preciction, error;
        double up_prediction;
        double up_error;
        double down_prediction;
        double down_error;
        for (int i = 0; i < itr; i++)
        {
            preciction = input * weight;
            error = Math.Pow((preciction - expected_value), 2);
            Console.WriteLine("Error : {0} Prediction : {1} \r\n", error, preciction);

            up_prediction = input * (weight + step_amount);
            up_error = Math.Pow((expected_value - up_prediction), 2);

            down_prediction = input * (weight - step_amount);
            down_error = Math.Pow((expected_value - down_prediction), 2);

            if (down_error < up_error)
                weight = weight - step_amount;
            if (down_error > up_error)
                weight = weight + step_amount;
        }
    }

    double[] predicted_results = new double[3];

    double[,] input_to_hidden_weights = {
        { -2, 9.5, 2.01},
        { -0.8, 7.2, 6.3},
        { -0.5, 0.45, 0.9},
    };

    double[,] hidden_to_output_weights = {
        { -1, 1.15, 0.11},
        { -0.18, 0.15, -0.01},
        { 0.25, -0.25, -0.1},
    };

    double[] expected_values = { 600, 10, -90 };


    double[] inputs = { 30, 87, 110 };
    fixed (double* ptrInputs = inputs, ptrPredictedResults = predicted_results)
    {
        hidden_layer_nn(ptrInputs, IN_LEN, HID_LEN, input_to_hidden_weights, OUT_LEN, hidden_to_output_weights, ptrPredictedResults);
        Console.WriteLine("Sad prediction: {0}", predicted_results[0]);
        Console.WriteLine("Sad Error: %f \r\n", find_error_simple(predicted_results[0], expected_values[0]));

        Console.WriteLine("Sick prediction: {0}", predicted_results[1]);
        Console.WriteLine("Sick prediction: %f \r\n", find_error_simple(predicted_results[1], expected_values[1]));

        Console.WriteLine("Active prediction: {0}", predicted_results[2]);
        Console.WriteLine("Active prediction: %f \r\n", find_error_simple(predicted_results[2], expected_values[2]));
    }
}
```

## 暴力學習
這感覺有點像是猜數字遊戲, 反正沒猜中就調整數值

```
#include <stdio.h>
#include <math.h>

void brute_force_learning(
    double input,
    double weight,
    double expected_value,
    double step_amount,
    int itr)
{
    double preciction, error;
    double up_prediction;
    double up_error;
    double down_prediction;
    double down_error;
    for (int i = 0; i < itr; i++)
    {
        preciction = input * weight;
        error = powf((preciction - expected_value),2);
        printf("Error : %f Prediction : %f \r\n", error, preciction);

        up_prediction = input * (weight + step_amount);
        up_error = powf((expected_value - up_prediction), 2);

        down_prediction = input * (weight - step_amount);
        down_error = powf((expected_value - down_prediction), 2);

        if (down_error < up_error)
            weight = weight - step_amount;
        if (down_error > up_error)
            weight = weight + step_amount;
    }
}

double weight = 0.5;
double input = 0.5;
double expected_value = 0.8;
double step_amount = 0.001;

int main()
{

    brute_force_learning(input , weight , expected_value , step_amount , 1200);

    return 0;
}
```

這裡在 c# 比較難搞, 因為 c# 用 double 會造成精度損失, 所以型別要改用 decimal 提高精度
這裡可以先看下實驗, 他會輸出 0.1999999999998181


```
double a = 5000.2, b = 5000;
double c = a - b;
Console.WriteLine(c);
//輸出 0.1999999999998181
```

另外 c# 的 Math.Pow 不支援 decimal, 所以只能自己算
或是這裡沿用 double 然後用 Math.Round 取個小數 8 ~ 10 位

```
decimal weight = 0.5m;
decimal input = 0.5m;
decimal expected_value = 0.8m;
decimal step_amount = 0.001m;

void brute_force_learning(
    decimal input,
    decimal weight,
    decimal expected_value,
    decimal step_amount,
    int itr)
{
    decimal preciction, error;
    decimal up_prediction;
    decimal up_error;
    decimal down_prediction;
    decimal down_error;
    for (int i = 0; i < itr; i++)
    {
        preciction = input * weight;
        error = (preciction - expected_value) * (preciction - expected_value);
        Console.WriteLine("Error : {0} Prediction : {1} \r\n", error, preciction);

        up_prediction = input * (weight + step_amount);
        up_error = (expected_value - up_prediction) * (expected_value - up_prediction);

        down_prediction = input * (weight - step_amount);
        down_error = (expected_value - down_prediction) * (expected_value - down_prediction);

        if (down_error < up_error)
            weight = weight - step_amount;
        if (down_error > up_error)
            weight = weight + step_amount;
    }
}

brute_force_learning(input, weight, expected_value, step_amount, 1200);
```

## Normalizing DataSets

他這裡比較簡單, 就把每個 array 裡面的最大值撈出來, 接著每個 array 的 element 除最大值

```
#include <stdio.h>
#include <math.h>
#define NUM_OF_FEATURES 2 // n values
#define NUM_OF_EXAMPLES 3 // m values

// Hours of workout
double x1[NUM_OF_EXAMPLES] = {2, 5, 1};
double _x1[NUM_OF_EXAMPLES];

// Hours of rest data
double x2[NUM_OF_EXAMPLES] = {8, 5, 8};
double _x2[NUM_OF_EXAMPLES];

// Muscle gain data
double y[NUM_OF_EXAMPLES] = {200, 90, 190};
double _y[NUM_OF_EXAMPLES];


void normalize_data(double *input_vector, double *output_vector, int LEN)
{
    int i;
    double max = input_vector[0];
    for (i = 1; i < LEN; i++)
    {
        if (input_vector[i] > max)
        {
            max = input_vector[i];
        }
    }

    // 正規化
    for (i = 0; i < LEN; i++)
    {
        output_vector[i] = input_vector[i] / max;
    }
}

int main()
{
    normalize_data(x1, _x1, NUM_OF_EXAMPLES);
    normalize_data(x2, _x2, NUM_OF_EXAMPLES);
    normalize_data(y, _y, NUM_OF_EXAMPLES);


    printf("Raw x1 data: \r\n");
    for (int i = 0; i < NUM_OF_EXAMPLES; i++)
    {
        printf(" %f ", x1[i]);
    }
    printf("\n\r");

    printf("Normalized _x1 data: \r\n");
    for (int i = 0; i < NUM_OF_EXAMPLES; i++)
    {
        printf(" %f ", _x1[i]);
    }
    printf("\n\r");


    printf("Raw x2 data: \r\n");
    for (int i = 0; i < NUM_OF_EXAMPLES; i++)
    {
        printf(" %f ", x2[i]);
    }
    printf("\n\r");

    printf("Normalized _x2 data: \r\n");
    for (int i = 0; i < NUM_OF_EXAMPLES; i++)
    {
        printf(" %f ", _x2[i]);
    }
    printf("\n\r");


    printf("Raw y data: \r\n");
    for (int i = 0; i < NUM_OF_EXAMPLES; i++)
    {
        printf(" %f ", y[i]);
    }
    printf("\n\r");

    printf("Normalized _y data: \r\n");
    for (int i = 0; i < NUM_OF_EXAMPLES; i++)
    {
        printf(" %f ", y[i]);
    }
    printf("\n\r");


    return 0;
}
```

c# 如下

```
unsafe
{
    int NUM_OF_FEATURES = 2;
    int NUM_OF_EXAMPLES = 3;

    double[] x1 = { 2, 5, 1 };
    double[] _x1 = new double[NUM_OF_EXAMPLES];

    double[] x2 = { 8, 5, 8 };
    double[] _x2 = new double[NUM_OF_EXAMPLES];

    double[] y = { 200, 90, 190 };
    double[] _y = new double[NUM_OF_EXAMPLES];

    void normalize_data(double* input_vector, double* output_vector, int LEN)
    {
        int i;
        double max = input_vector[0];
        for (i = 1; i < LEN; i++)
        {
            if (input_vector[i] > max)
            {
                max = input_vector[i];
            }
        }

        // 正規化
        for (i = 0; i < LEN; i++)
        {
            output_vector[i] = input_vector[i] / max;
        }
    }

    fixed (double* ptrX1 = x1, _ptrX1 = _x1, ptrX2 = x2, _ptrX2 = _x2, ptrY = y, _ptrY = _y)
    {
        normalize_data(ptrX1, _ptrX1, NUM_OF_EXAMPLES);
        normalize_data(ptrX2, _ptrX2, NUM_OF_EXAMPLES);
        normalize_data(ptrY, _ptrY, NUM_OF_EXAMPLES);

    }

    Console.Write("Raw x1 data: \r\n");
    for (int i = 0; i < NUM_OF_EXAMPLES; i++)
    {
        Console.Write(" {0} ", x1[i]);
    }
    Console.Write("\n\r");

    Console.Write("Normalized _x1 data: \r\n");
    for (int i = 0; i < NUM_OF_EXAMPLES; i++)
    {
        Console.Write(" {0} ", _x1[i]);
    }
    Console.Write("\n\r");


    Console.Write("Raw x2 data: \r\n");
    for (int i = 0; i < NUM_OF_EXAMPLES; i++)
    {
        Console.Write(" {0} ", x2[i]);
    }
    Console.Write("\n\r");

    Console.Write("Normalized _x2 data: \r\n");
    for (int i = 0; i < NUM_OF_EXAMPLES; i++)
    {
        Console.Write(" {0} ", _x2[i]);
    }
    Console.Write("\n\r");


    Console.Write("Raw y data: \r\n");
    for (int i = 0; i < NUM_OF_EXAMPLES; i++)
    {
        Console.Write(" {0} ", y[i]);
    }
    Console.Write("\n\r");

    Console.Write("Normalized _y data: \r\n");
    for (int i = 0; i < NUM_OF_EXAMPLES; i++)
    {
        Console.Write(" {0} ", y[i]);
    }
    Console.Write("\n\r");


}
```

## Random Initialzation of Weights

`Synapse 突觸` 神經元之間，或神經元與肌細胞、腺體之間通信的特異性接頭

他這裡用兩個特徵 `hours of work out` `hours of rest data` 當作範例, 中間有三個隱藏的 `node` 最後有一個輸出
然後跑亂數, 最後得到權重 (Synapse)

```
synapse 0 weight:
0.500000  0.600000 

0.800000  0.500000

0.400000  0.000000

synapse 1 weight:
0.500000  0.600000  0.800000
```

c 程式碼

```
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

//特徵數量
#define NUM_OF_FEATURES 2 // n values
//範例資料筆數
#define NUM_OF_EXAMPLES 3 // m values

//隱藏層節點
#define NUM_OF_HID_NODES 3
//輸出節點
#define NUM_OF_OUT_NODES 1

// Hours of workout
double x1[NUM_OF_EXAMPLES] = {2, 5, 1};
double _x1[NUM_OF_EXAMPLES];

// Hours of rest data
double x2[NUM_OF_EXAMPLES] = {8, 5, 8};
double _x2[NUM_OF_EXAMPLES];

// Muscle gain data
double y[NUM_OF_EXAMPLES] = {200, 90, 190};
double _y[NUM_OF_EXAMPLES];

void normalize_data(double *input_vector, double *output_vector, int LEN)
{
    int i;
    double max = input_vector[0];
    for (i = 1; i < LEN; i++)
    {
        if (input_vector[i] > max)
        {
            max = input_vector[i];
        }
    }

    // 正規化
    for (i = 0; i < LEN; i++)
    {
        output_vector[i] = input_vector[i] / max;
    }
}

void weight_random_initialization(int HIDDEN_LEN, int INPUT_LEN, double weights_matrix[HIDDEN_LEN][INPUT_LEN])
{
    srand(2);
    double d_rand;

    for (int i = 0; i < HIDDEN_LEN; i++)
    {
        for (int j = 0; j < INPUT_LEN; j++)
        {
            d_rand = (rand() % 10);
            d_rand /= 10;

            weights_matrix[i][j] = d_rand;
        }
    }
}

//input layer to hidden layer weights buffer
double syn0[NUM_OF_HID_NODES][NUM_OF_FEATURES];

//hidden layer to output layer weights buffer
double syn1[NUM_OF_OUT_NODES][NUM_OF_HID_NODES];
int main()
{
    weight_random_initialization(NUM_OF_HID_NODES, NUM_OF_FEATURES , syn0);
    weight_random_initialization(NUM_OF_OUT_NODES, NUM_OF_HID_NODES , syn1);

    //synapse 0 weight
    printf("synapse 0 weight:\n");
    for(int i =0 ; i < NUM_OF_HID_NODES; i ++) {
        for(int j = 0 ; j < NUM_OF_FEATURES ; j++){
            printf(" %f ", syn0[i][j]);
        }
        printf("\n\r");
        printf("\n\r");
    }


    //synapse 1 weight
    printf("synapse 1 weight:\n");
    for(int i =0 ; i < NUM_OF_OUT_NODES; i ++) {
        for(int j = 0 ; j < NUM_OF_HID_NODES ; j++){
            printf(" %f ", syn1[i][j]);
        }
        printf("\n\r");
        printf("\n\r");
    }

    return 0;
}
```

c# 如下

這裡唯一不同應該是撈亂數的方法, c 的 rand() 會撈 0 ~ 32767, 在 c# 可以用 Next(0,32767) 來指定

```
unsafe
{
    int NUM_OF_FEATURES = 2;
    int NUM_OF_EXAMPLES = 3;
    int NUM_OF_HID_NODES = 3;
    int NUM_OF_OUT_NODES = 1;

    double[] x1 = { 2, 5, 1 };
    double[] _x1 = new double[NUM_OF_EXAMPLES];

    double[] x2 = { 8, 5, 8 };
    double[] _x2 = new double[NUM_OF_EXAMPLES];

    double[] y = { 200, 90, 190 };
    double[] _y = new double[NUM_OF_EXAMPLES];

    void weight_random_initialization(int HIDDEN_LEN, int INPUT_LEN, double[,] weights_matrix)
    {
        double d_rand;
        var rnd = new Random();

        for (int i = 0; i < HIDDEN_LEN; i++)
        {
            for (int j = 0; j < INPUT_LEN; j++)
            {
                d_rand = (rnd.Next(0 , 32767) % 10);
                d_rand /= 10;

                weights_matrix[i, j] = d_rand;
            }
        }
    }

    //input layer to hidden layer weights buffer
    double[,] syn0 = new double[NUM_OF_HID_NODES, NUM_OF_FEATURES];

    //hidden layer to output layer weights buffer
    double[,] syn1 = new double[NUM_OF_OUT_NODES, NUM_OF_HID_NODES];

    weight_random_initialization(NUM_OF_HID_NODES, NUM_OF_FEATURES, syn0);
    weight_random_initialization(NUM_OF_OUT_NODES, NUM_OF_HID_NODES, syn1);


    //synapse 0 weight
    Console.Write("synapse 0 weight:\n");
    for (int i = 0; i < NUM_OF_HID_NODES; i++)
    {
        for (int j = 0; j < NUM_OF_FEATURES; j++)
        {
            Console.Write(" {0} ", syn0[i, j]);
        }
        Console.Write("\n\r");
        Console.Write("\n\r");
    }


    //synapse 1 weight
    Console.Write("synapse 1 weight:\n");
    for (int i = 0; i < NUM_OF_OUT_NODES; i++)
    {
        for (int j = 0; j < NUM_OF_HID_NODES; j++)
        {
            Console.Write(" {0} ", syn1[i, j]);
        }
        Console.Write("\n\r");
        Console.Write("\n\r");
    }

}
```

## Forward Propagation

```
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

// 特徵數量
#define NUM_OF_FEATURES 2 // n values
// 範例資料筆數
#define NUM_OF_EXAMPLES 3 // m values

// 隱藏層節點
#define NUM_OF_HID_NODES 3
// 輸出節點
#define NUM_OF_OUT_NODES 1

void normalize_data(double *input_vector, double *output_vector, int LEN)
{
    int i;
    double max = input_vector[0];
    for (i = 1; i < LEN; i++)
    {
        if (input_vector[i] > max)
        {
            max = input_vector[i];
        }
    }

    // 正規化
    for (i = 0; i < LEN; i++)
    {
        output_vector[i] = input_vector[i] / max;
    }
}

void weight_random_initialization(int HIDDEN_LEN, int INPUT_LEN, double weights_matrix[HIDDEN_LEN][INPUT_LEN])
{
    srand(2);
    double d_rand;

    for (int i = 0; i < HIDDEN_LEN; i++)
    {
        for (int j = 0; j < INPUT_LEN; j++)
        {
            d_rand = (rand() % 10);
            d_rand /= 10;

            weights_matrix[i][j] = d_rand;
        }
    }
}

void normalize_data_2d(int ROW, int COL, double input_matrix[ROW][COL], double output_matrix[ROW][COL])
{
    double max = -999999;
    for (int y = 0; y < ROW; y++)
    {
        for (int x = 0; x < COL; x++)
        {
            if (input_matrix[y][x] > max)
                max = input_matrix[y][x];
        }
    }

    for (int y = 0; y < ROW; y++)
    {
        for (int x = 0; x < COL; x++)
        {
            output_matrix[y][x] = input_matrix[y][x] / max;
        }
    }
}

void weight_random_initialzation_1d(double *output_vector, int LEN)
{
    double d_rand;
    srand(2);
    for (int j = 0; j < LEN; j++)
    {
        d_rand = (rand() % 10);
        d_rand /= 10;
        output_vector[j] = d_rand;
    }
}

void matrix_vector_multiply(
    double *input_vector,
    int INPUT_LEN,
    double *output_vector,
    int OUTPUT_LEN,
    double weight_matrix[OUTPUT_LEN][INPUT_LEN])
{

    for (int k = 0; k < OUTPUT_LEN; k++)
    {
        for (int i = 0; i < INPUT_LEN; i++)
        {
            output_vector[k] += input_vector[i] * weight_matrix[k][i];
        }
    }
}

// 計算加權總和
double weighted_sum(double *input, double *weight, int LEN)
{
    double output;
    for (int i = 0; i < LEN; i++)
    {
        output += input[i] * weight[i];
    }
    return output;
}

// 包裝函數
double multiple_input_single_output(double *input, double *weight, int LEN)
{
    double predicted_value;

    predicted_value = weighted_sum(input, weight, LEN);
    return predicted_value;
}

void multiple_input_multiple_output_nn(
    double *input_vector,
    int INPUT_LEN,
    double *output_vector,
    int OUTPUT_LEN,
    double weight_matrix[OUTPUT_LEN][INPUT_LEN])
{
    matrix_vector_multiply(input_vector, INPUT_LEN, output_vector, OUTPUT_LEN, weight_matrix);
}

double sigmoid(double x)
{
    double result = 1 / (1 + exp(-x));
    return result;
}

void vector_sigmoid(double *input_vector, double *output_vector, int LEN)
{
    for (int i = 0; i < LEN; i++)
        output_vector[i] = sigmoid(input_vector[i]);
}

double raw_x[NUM_OF_FEATURES][NUM_OF_EXAMPLES] = {
    {2, 5, 1},
    {8, 5, 8}};

double raw_y[1][NUM_OF_EXAMPLES] = {{200, 90, 190}};

/* Train x
   2/8 5/8 1/8
   8/8 5/8 8/8
   dim = nx X m
 */
double train_x[NUM_OF_FEATURES][NUM_OF_EXAMPLES];

/* Train y
   200/200 90/200 190/200
 */
double train_y[1][NUM_OF_EXAMPLES];

// input layer to hidden layer weights buffer
double syn0[NUM_OF_HID_NODES][NUM_OF_FEATURES];

// hidden layer to output layer weights buffer
double syn1[NUM_OF_OUT_NODES][NUM_OF_HID_NODES];

double train_x_eg1[NUM_OF_FEATURES];
double train_y_eg1;
double z1_eg1[NUM_OF_HID_NODES];
double a1_eg1[NUM_OF_HID_NODES];
double z2_eg1;
double yhat_eg1;

int main()
{

    normalize_data_2d(NUM_OF_FEATURES, NUM_OF_EXAMPLES, raw_x, train_x);
    normalize_data_2d(1, NUM_OF_EXAMPLES, raw_y, train_y);

    train_x_eg1[0] = train_x[0][0];
    train_x_eg1[1] = train_x[1][0];

    train_y_eg1 = train_y[0][0];

    printf("train_x_eg1 is [%f %f]", train_x_eg1[0], train_x_eg1[1]);
    printf("\n\r");
    printf("\n\r");

    printf("train_y_eg1 is %f", train_y_eg1);
    printf("\n\r");
    printf("\n\r");

    weight_random_initialization(NUM_OF_HID_NODES, NUM_OF_FEATURES, syn0);
    // weight_random_initialization(NUM_OF_OUT_NODES, NUM_OF_HID_NODES, syn1);

    // synapse 0 weight
    printf("synapse 0 weight:\n");
    for (int i = 0; i < NUM_OF_HID_NODES; i++)
    {
        for (int j = 0; j < NUM_OF_FEATURES; j++)
        {
            printf(" %f ", syn0[i][j]);
        }
        printf("\n\r");
        printf("\n\r");
    }

    weight_random_initialzation_1d(syn1, NUM_OF_OUT_NODES);
    printf("\n\r");
    printf("\n\r");
    for (int i = 0; i < NUM_OF_OUT_NODES; i++)
    {
        printf("synapse 1 [%f %f %f]", syn1[0], syn1[1], syn1[2]);
    }
    printf("\n\r");
    printf("\n\r");

    // z1
    multiple_input_multiple_output_nn(train_x_eg1, NUM_OF_FEATURES, z1_eg1, NUM_OF_HID_NODES, syn0);
    printf("\n\r");
    printf("\n\r");

    printf(" z_eg1 = [%f %f %f]", z1_eg1[0], z1_eg1[1], z1_eg1[2]);
    printf("\n\r");
    printf("\n\r");

    // a1
    vector_sigmoid(z1_eg1, a1_eg1, NUM_OF_HID_NODES);
    printf(" a_eg1 = [%f %f %f]", a1_eg1[0], a1_eg1[1], a1_eg1[2]);
    printf("\n\r");
    printf("\n\r");

    z2_eg1 = multiple_input_single_output(a1_eg1 , syn1 , NUM_OF_HID_NODES);
    printf("z2_eg1 : %f", z2_eg1);

    //yhat
    yhat_eg1 = sigmoid(z2_eg1);
    printf("\n\r");
    printf("\n\r");

    printf("yhat_eg1 : %f", yhat_eg1);
    printf("\n\r");
    printf("\n\r");

    return 0;
}
```

這裡先新增 `normalize_data_2d` 函數, 先取 matrix 內的最大值, 接著 loop 每個數值 / max 即可


```
void normalize_data_2d(int ROW, int COL, double input_matrix[ROW][COL], double output_matrix[ROW][COL])
{
    double max = -999999;
    for (int y = 0; y < ROW; y++)
    {
        for (int x = 0; x < COL; x++)
        {
            if (input_matrix[y][x] > max)
                max = input_matrix[y][x];
        }
    }

    for (int y = 0; y < ROW; y++)
    {
        for (int x = 0; x < COL; x++)
        {
            output_matrix[y][x] = input_matrix[y][x] / max;
        }
    }
}
```

然後宣告 `2(高 NUM_OF_FEATURES) * 3(寬 NUM_OF_EXAMPLES)` 的 raw_x 變數, 接著讓他正規化

```
double raw_x[NUM_OF_FEATURES][NUM_OF_EXAMPLES] = {
    {2, 5, 1},
    {8, 5, 8}
};

/*
2/8 5/8 1/8
8/8 5/8 8/8

0.250000 0.625000 0.125000
1.000000 0.625000 1.000000
*/
double train_x[NUM_OF_FEATURES][NUM_OF_EXAMPLES];
```

接著宣告 `1(高) * 3(寬 NUM_OF_EXAMPLES)` 的 raw_y 變數, 呼叫正規化

```
double raw_y[1][NUM_OF_EXAMPLES] = {
	{200, 90, 190}
};

/* 
200/200 90/200 190/200

1.000000 0.450000 0.950000
*/
double train_y[1][NUM_OF_EXAMPLES];
```

接續定義函數 `weight_random_initialization`
他會隨機取得 0 ~ 9 之間的數字, 最後 /10 會得到 0.x 塞入 2d array 內
最後就可以獲得亂數 0.0 ~ 0.9 的權重
`weight_random_initialzation_1d` 也是類似效果, 只不過換種寫法適用 1d array

```
void weight_random_initialization(int HIDDEN_LEN, int INPUT_LEN, double weights_matrix[HIDDEN_LEN][INPUT_LEN])
{
    srand(2);
    double d_rand;

    for (int i = 0; i < HIDDEN_LEN; i++)
    {
        for (int j = 0; j < INPUT_LEN; j++)
        {
            d_rand = (rand() % 10);
            d_rand /= 10;

            weights_matrix[i][j] = d_rand;
        }
    }
}
```

接著呼叫之前寫過的函數 `multiple_input_multiple_output_nn`
train_x_eg1 => input
syn0 => 輸入層到隱藏層的權重矩陣
計算隱藏層的加權總和 z1_eg1

```
multiple_input_multiple_output_nn(train_x_eg1, NUM_OF_FEATURES, z1_eg1, NUM_OF_HID_NODES, syn0);
```

然後定義激活函數 `sigmoid`

```
double sigmoid(double x)
{
    double result = 1 / (1 + exp(-x));
    return result;
}

void vector_sigmoid(double *input_vector, double *output_vector, int LEN)
{
    for (int i = 0; i < LEN; i++)
        output_vector[i] = sigmoid(input_vector[i]);
}
```

以激活函數算出隱藏層的輸出 a1_eg1

```
vector_sigmoid(z1_eg1, a1_eg1, NUM_OF_HID_NODES);

```

以 `multiple_input_single_output` 算出輸出層的加權總和 z2_eg1

```
z2_eg1 = multiple_input_single_output(a1_eg1, syn1, NUM_OF_HID_NODES);
```

以激活函數算出最終值

```
yhat_eg1 = sigmoid(z2_eg1);
```

他的 c# 如下


```
unsafe
{
    int NUM_OF_FEATURES = 2;
    int NUM_OF_EXAMPLES = 3;
    int NUM_OF_HID_NODES = 3;
    int NUM_OF_OUT_NODES = 1;


    void weight_random_initialization(int HIDDEN_LEN, int INPUT_LEN, double[,] weights_matrix)
    {
        Random random = new Random();
        double d_rand;

        for (int i = 0; i < HIDDEN_LEN; i++)
        {
            for (int j = 0; j < INPUT_LEN; j++)
            {
                //d_rand = (rand() % 10);
                d_rand = random.Next(0, 9);
                d_rand /= 10;

                weights_matrix[i, j] = d_rand;
            }
        }
    }

    void weight_random_initialzation_1d(double* output_vector, int LEN)
    {
        double d_rand;
        Random random = new Random();
        //srand(2);
        for (int j = 0; j < LEN; j++)
        {
            d_rand = random.Next(0, 9);
            //d_rand = (rand() % 10);
            d_rand /= 10;
            output_vector[j] = d_rand;
        }
    }

    void matrix_vector_multiply(
        double* input_vector,
        int INPUT_LEN,
        double* output_vector,
        int OUTPUT_LEN,
        double[,] weight_matrix)
    {

        for (int k = 0; k < OUTPUT_LEN; k++)
        {
            for (int i = 0; i < INPUT_LEN; i++)
            {
                output_vector[k] += input_vector[i] * weight_matrix[k, i];
            }
        }
    }

    void multiple_input_multiple_output_nn(
        double* input_vector,
        int INPUT_LEN,
        double* output_vector,
        int OUTPUT_LEN,
        double[,] weight_matrix)
    {
        matrix_vector_multiply(input_vector, INPUT_LEN, output_vector, OUTPUT_LEN, weight_matrix);
    }


    double sigmoid(double x)
    {
        double result = 1 / (1 + Math.Exp(-x));
        return result;
    }

    void vector_sigmoid(double* input_vector, double* output_vector, int LEN)
    {
        for (int i = 0; i < LEN; i++)
            output_vector[i] = sigmoid(input_vector[i]);
    }


    void normalize_data_2d(int ROW, int COL, double[,] input_matrix, double[,] output_matrix)
    {
        double max = -999999;
        for (int y = 0; y < ROW; y++)
        {
            for (int x = 0; x < COL; x++)
            {
                if (input_matrix[y, x] > max)
                    max = input_matrix[y, x];
            }
        }

        for (int y = 0; y < ROW; y++)
        {
            for (int x = 0; x < COL; x++)
            {
                output_matrix[y, x] = input_matrix[y, x] / max;
            }
        }
    }

    // 計算加權總和
    double weighted_sum(double* input, double* weight, int LEN)
    {
        double output = 0;
        for (int i = 0; i < LEN; i++)
        {
            output += input[i] * weight[i];
        }
        return output;
    }

    // 包裝函數
    double multiple_input_single_output(double* input, double* weight, int LEN)
    {
        double predicted_value;

        predicted_value = weighted_sum(input, weight, LEN);
        return predicted_value;
    }


    //input layer to hidden layer weights buffer
    double[,] syn0 = new double[NUM_OF_HID_NODES, NUM_OF_FEATURES];

    //hidden layer to output layer weights buffer
    double[,] syn1 = new double[NUM_OF_OUT_NODES, NUM_OF_HID_NODES];

    double[] train_x_eg1 = new double[NUM_OF_FEATURES];
    double train_y_eg1;
    double[] z1_eg1 = new double[NUM_OF_HID_NODES];
    double[] a1_eg1 = new double[NUM_OF_HID_NODES];
    double z2_eg1;
    double yhat_eg1;

    double[,] raw_x = {
        {2, 5, 1},
        {8, 5, 8}
    };
    double[,] train_x = new double[2, 3];
    double[,] raw_y = {
        {200, 90, 190}
    };
    double[,] train_y = new double[1, 3];





    normalize_data_2d(NUM_OF_FEATURES, NUM_OF_EXAMPLES, raw_x, train_x);
    normalize_data_2d(1, NUM_OF_EXAMPLES, raw_y, train_y);

    train_x_eg1[0] = train_x[0, 0];
    train_x_eg1[1] = train_x[1, 0];

    train_y_eg1 = train_y[0, 0];

    Console.WriteLine("train_x_eg1 is [{0} {1}]", train_x_eg1[0], train_x_eg1[1]);

    Console.WriteLine("train_y_eg1 is {0}", train_y_eg1);

    weight_random_initialization(NUM_OF_HID_NODES, NUM_OF_FEATURES, syn0);
    // weight_random_initialization(NUM_OF_OUT_NODES, NUM_OF_HID_NODES, syn1);

    // synapse 0 weight
    Console.WriteLine("synapse 0 weight:\n");
    for (int i = 0; i < NUM_OF_HID_NODES; i++)
    {
        for (int j = 0; j < NUM_OF_FEATURES; j++)
        {
            Console.Write(" {0} ", syn0[i, j]);
        }
        Console.WriteLine();
    }

    fixed (double* ptrSyn1 = syn1)
    {
        weight_random_initialzation_1d(ptrSyn1, NUM_OF_OUT_NODES);
        //weight_random_initialzation_1d(syn1, NUM_OF_OUT_NODES);
        Console.WriteLine("\n\r");
        for (int i = 0; i < NUM_OF_OUT_NODES; i++)
        {
            //Console.Write("synapse 1 [%f %f %f]", syn1[0], syn1[1], syn1[2]);
            Console.Write("synapse 1 [{0} {1} {2}]", syn1[0, 0], syn1[0, 1], syn1[0, 2]);
        }
        Console.WriteLine();
    }

    // z1
    fixed (double* ptrTrainXEg1 = train_x_eg1, ptrZ1Eg1 = z1_eg1, ptrA1Eg1 = a1_eg1, ptrSyn1 = syn1)
    {
        multiple_input_multiple_output_nn(ptrTrainXEg1, NUM_OF_FEATURES, ptrZ1Eg1, NUM_OF_HID_NODES, syn0);

        //multiple_input_multiple_output_nn(train_x_eg1, NUM_OF_FEATURES, z1_eg1, NUM_OF_HID_NODES, syn0);
        Console.WriteLine();
        Console.WriteLine();

        Console.WriteLine(" z_eg1 = [{0} {1} {2}]", z1_eg1[0], z1_eg1[1], z1_eg1[2]);
        Console.WriteLine();

        // a1
        //vector_sigmoid(z1_eg1, a1_eg1, NUM_OF_HID_NODES);
        vector_sigmoid(ptrZ1Eg1, ptrA1Eg1, NUM_OF_HID_NODES);
        Console.WriteLine(" a_eg1 = [{0} {1} {2}]", a1_eg1[0], a1_eg1[1], a1_eg1[2]);

        z2_eg1 = multiple_input_single_output(ptrA1Eg1, ptrSyn1, NUM_OF_HID_NODES);
        Console.WriteLine("z2_eg1 : {0}", z2_eg1);

        //yhat
        yhat_eg1 = sigmoid(z2_eg1);
        Console.WriteLine();

        Console.WriteLine("yhat_eg1 : {0}", yhat_eg1);
    }

}
```
